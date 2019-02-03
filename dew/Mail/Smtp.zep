namespace Dew\Mail;
/**
 * Dew\Mail\Smtp
 */
class Smtp extends \Dew\Mail
{
	const BUFSIZE = 4096;

	protected sock;
	protected scheme;
	protected host;
	protected port;
	protected timeout;
	protected fqdn;
	protected svr_name;
	protected svr_info;

	/**
	 * constructor
	 * @access	public
	 * @param	string	from_addr
	 * @param	string	from_name
	 * @param	array	opts
	 */
	public function __construct (String from_addr, String from_name="", Array opts=[])
	{
		parent::__construct(from_addr, from_name, opts);
		this->parseOptions(opts);

		let this->svr_name = "";
		let this->svr_info = [];

	}

	/**
	 * destructor
	 * @access	public
	 */
	public function __destruct ()
	{
		if this->isConnected() {
			this->quit();
		}
	}

	/**
	 * parse host data
	 * @access	private
	 * @param	array	opts
	 * @return	void
	 */
	private function parseOptions (Array opts=[]) -> void
	{
		let this->scheme = "smtp";
		let this->host = "127.0.0.1";
		let this->port = 25;
		let this->timeout = 30;
		let this->fqdn = (string)php_uname("n");

		if !isset(opts["host"]) { return; }

		var tmp, val;
		let tmp = parse_url(opts["host"]);

		// Scheme
		if fetch val, tmp["scheme"] {
			if in_array(val, ["smtp", "smtps", "tls"]) {
				let this->scheme = "smtp";
			} else {
				throw new \Dew\Mail\Exception("Scheme \"".val."\" is not supported.");
			}
		}

		// Host
		if fetch val, tmp["host"] {
			let this->host = (string)val;
		}

		// Port
		if fetch val, tmp["port"] {
			if filter_var(val, FILTER_VALIDATE_INT, ["min_range":0, "max_range":65535])!==false {
				let this->port = (int)val;
			}
		}

		// Timeout
		if fetch val, opts["timeout"] {
			if filter_var(val, FILTER_VALIDATE_INT, ["min_range":0])!==false {
				let this->timeout = (int)val;
			}
		}

		// FQDN
		if fetch val, opts["fqdn"] {
			let this->fqdn = (string)val;
		}

		return;
	}

	/**
	 * whether if connected or not.
	 * @access	private
	 * @return	boolean
	 */
	private function isConnected () -> Boolean
	{
		return this->sock ? true : false;
	}

	/**
	 * connect
	 * @access	private
	 * @return	void
	 */
	private function connect () -> Bool
	{
		if this->isConnected() {
			return true;
		}

		// Socket
		String socket = "";
		var context;
		let context = stream_context_create();
		if this->scheme=="smtps" {
			let socket = (string)sprintf("ssl://%s:%d", this->host, this->port);
		} else {
			let socket = (string)sprintf("tcp://%s:%d", this->host, this->port);
		}

		var err_no, err_msg, m;
		let this->sock = stream_socket_client(socket, err_no, err_msg, 10, STREAM_CLIENT_CONNECT, context);
		if !this->sock {
			throw new \Dew\Mail\Exception(err_msg);
		}
		stream_set_timeout(this->sock, this->timeout);
		String res = (string)fread(this->sock, self::BUFSIZE);
		if preg_match("#\d+ ([^ ]+)#", res->trim(), m) {
			let this->svr_name = m[1];
		}

		// EHLO
		this->ehlo();

		// STARTTLS
		this->starttls();

		// MAIL FROM
		this->mail(this->from["addr"]);

		return true;
	}

	/*
	 * Command
	 * @access	private
	 * @return	boolean
	 * @throws	\Dew\Mail\Exception
	 */
	private function command (const String cmd) -> Bool
	{
		this->connect();
		var res;
		let res = fwrite(this->sock, cmd."\r\n");
		fflush(this->sock);
		if res===false {
			throw new \Dew\Mail\Exception("Command Failure \"".cmd."\"");
		}

		return true;
	}

	/**
	 * get response
	 * @access	private
	 * @return	string
	 */
	private function getResponse () -> String
	{
		String content = "";
		let content = (string)fread(this->sock, self::BUFSIZE);
		return content->trim();
	}

	/*
	 * HELO command
	 * @access	private
	 * @return	boolean
	 */
	private function ehlo () -> Boolean
	{
		String res, line;
		Int status;
		var match, k, v, m;

		this->command((string)sprintf("EHLO %s", this->fqdn));
		let res = (string)this->getResponse();
		preg_match_all("#(\d+)(\-|\s)(.+)\r?\n#", res, match, PREG_SET_ORDER);
		for k,v in match {
			let k = (int)k;
			let status = (int)v[1];
			let line = (string)trim(v[3]);
			if k===0 {
				if preg_match("#(\w[\w\_\.]+\w)#", line, m) {
					let this->svr_name = (string)m[1];
				}
				continue;
			}
			if strpos(line, "SIZE ")===0 {
				let this->svr_info["size"] = (int)substr(line, 5);
				continue;
			}
			if strpos(line, "AUTH ")===0 {
				let this->svr_info["auth"] = (array)explode(" ", substr(line->lower(), 5));
				continue;
			}
			if strpos(line, "AUTH=")===0 {
				continue;
			}
			let this->svr_info[line->lower()] = true;
		}

		// 250
		if status!=250 {
			throw new \Dew\Mail\Exception("File to say hello.", status);
		}
		return true;
	}

	/*
	 * STARTTLS Command
	 * @access	private
	 * @return	boolean
	 */
	private function starttls () -> Boolean
	{
		if this->scheme!="tls" {
			return true;
		}
		if !isset this->svr_info["starttls"] {
			return false;
		}
/*
		if !isset(this->svr_info["starttls"]) || !this->svr_info["starttls"] {
			return false;
		}

		String res = "", msg = "";
		Int status = 0;
		var m;

		this->command("STARTTLS");
		let res = (string)this->getResponse();
		if preg_match("#(\d+)\s(.+)#", res->trim(), m) {
			let status = (int)m[1];
			let msg = (string)m[2];
		}

		if status!=220 {
			throw new \Dew\Mail\Exception(msg, status);
		}

		Int crypto_type;
		let crypto_type = (int)constant("STREAM_CRYPTO_METHOD_TLS_CLIENT");
		if defined("STREAM_CRYPTO_METHOD_TLSv1_3_CLIENT") {
			let crypto_type |= (int)constant("STREAM_CRYPTO_METHOD_TLSv1_3_CLIENT");
		}
		if defined("STREAM_CRYPTO_METHOD_TLSv1_2_CLIENT") {
			let crypto_type |= (int)constant("STREAM_CRYPTO_METHOD_TLSv1_2_CLIENT");
		}
		if defined("STREAM_CRYPTO_METHOD_TLSv1_1_CLIENT") {
			let crypto_type |= (int)constant("STREAM_CRYPTO_METHOD_TLSv1_1_CLIENT");
		}
		stream_socket_enable_crypto(this->sock, true, crypto_type);
*/
		return true;
	}

	/*
	 * AUTH Command
	 * @access	private
	 * @param	string	user
	 * @param	string	password
	 * @return	boolean
	 * @todo
	 */
	private function auth (String user, String password) -> Boolean
	{
		// 250, 334
/*
		String cmd;
		let cmd = "AUTH";
		this->command(cmd);
*/
		return true;
	}

	/*
	 * Authenticate by PLAIN
	 * @access	private
	 * @return	
	 * AUTH PLAIN
	 * base64_encode("UserId\0UserId\0Password")
	 */
	private function authByPlain ()
	{
	}

	/*
	 * Authenticate by LOGIN
	 * @access	private
	 * @return
	 * AUTH LOGIN
	 * base64_encode("UserId")
	 * base64_encode("Password")
	 */
	private function authByLogin ()
	{
	
	}

	/*
	 * MAIL Command
	 * @access	private
	 * @param	string	addr
	 * @return	boolean
	 */
	private function mail (String addr) -> Boolean
	{
		String res = "", msg = "";
		Int status = 0;
		var m;

		this->command((string)sprintf("MAIL FROM: <%s>", addr));
		let res = (string)this->getResponse();
		if preg_match("#(\d{3}) (.+)#", res, m) {
			let status = (int)m[1];
			let msg = (string)m[2];
		}

		// 250
		if status!=250 {
			throw new \Dew\Mail\Exception(msg, status);
		}
		return true;
	}

	/*
	 * RCPT Command
	 * @access	private
	 * @param	string	addr
	 * @return	boolean
	 */
	private function rcpt (String addr) -> Boolean
	{
		String res = "", msg = "";
		Int status = 0;
		var m;

		this->command((string)sprintf("RCPT TO: <%s>", addr));
		let res = (string)this->getResponse();
		if preg_match("#(\d{3}) (.+)#", res, m) {
			let status = (int)m[1];
			let msg = (string)m[2];
		}

		// 250, 251
		if status!=250 && status!=251 {
			throw new \Dew\Mail\Exception(msg, status);
		}
		return true;
	}

	/*
	 * DATA Command
	 * @access	private
	 * @param	string	data
	 * @return	boolean
	 */
	private function data () -> Boolean
	{
		String res = "", msg = "";
		Int status = 0;
		var m;

		this->command("DATA");
		let res = (string)this->getResponse();
		if preg_match("#(\d{3}) (.+)#", res, m) {
			let status = (int)m[1];
			let msg = (string)m[2];
		}
		// 354
		if status!=354 {
			throw new \Dew\Mail\Exception(msg, status);
		}

		var k, v;
		// Header
		Array headers = (array)this->createHeader();
		if isset headers["Bcc"] {
			unset headers["Bcc"];
		}

		// To
		if count(this->to)>0 {
			let headers["To"] = (string)this->createRecipient(this->to);
		}

		String body = "";
		for k,v in headers {
			let body .= k . ": " . v ."\r\n";
		}

		let body .= "\r\n".str_replace("\r\n.\r\n", "\r\n..\r\n", this->body) . "\r\n.\r\n";
		fwrite(this->sock, body);

		return true;
	}

	/*
	 * RSET Command
	 * @access	private
	 * @return	boolean
	 */
	private function rset () -> Boolean
	{
		String res = "", msg = "";
		Int status = 0;
		var m;

		this->command("RSET");
		let res = (string)this->getResponse();
		if preg_match("#(\d{3}) (.+)#", res, m) {
			let status = (int)m[1];
			let msg = (string)m[2];
		}

		// 250, 200
		if status!=250 && status!=200 {
			throw new \Dew\Mail\Exception(msg, status);
		}
		return true;
	}

	/*
	 * QUIT Command
	 * @access	private
	 * @return	boolean
	 */
	private function quit () -> Boolean
	{
		if !is_resource(this->sock) {
			return true;
		}

		this->command("QUIT");
		fclose(this->sock);
		return true;
	}

	/**
	 * RSET Command
	 * @access	private
	 * @return	void
	 */
	public function reset () -> void
	{
		this->rset();
		this->initialize();
	}

	/*
	 * Send
	 * @access	public
	 * @return	boolean
	 * @throws	\Dew\Mail\Exception
	 */
	public function send () -> Boolean
	{
		// RCPT TO
		var v1, v2;
		for v1 in [this->to, this->cc, this->bcc] {
			for v2 in v1 {
				this->rcpt(v2["addr"]);
			}			
		}
		// DATA
		this->data();

		return true;
	}
}
