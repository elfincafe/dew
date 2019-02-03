namespace Dew;
/**
 * Dew\Mail
 */
class Mail
{
	const NAME = "Dew Mailer";
	const LINE_MUST = 998;
	const LINE_SHOULD = 78;
	const LINE_BREAK = "\r\n";

	protected to;
	protected cc;
	protected bcc;
	protected from;
	protected subject;
	protected body;
	protected headers;
	protected opts;
	protected vars;

	/**
	 * constructor
	 * @access	public
	 * @param	string	addr
	 * @param	string	from
	 * @param	array	opts
	 */
	public function __construct (String addr, String name="", Array opts=[])
	{
		this->initialize();

		this->recipient("from", addr, name);

		// Header
		this->returnPath(addr);
		this->replyTo(addr);

		let this->opts = opts;
	}

	/**
	 * destructor
	 * @access	public
	 */
	public function __destruct ()
	{
	}

	/**
	 * Magic Method
	 * @accses	public
	 * @param	string	key
	 * @return	mixed
	 */
	public function __get (String key)
	{
		if isset this->vars[key->lower()] {
			return this->vars[key];
		} else {
			return null;
		}
	}

	/**
	 * Magic Method
	 * @access	public
	 * @param	String	key
	 * @param	mixed	value
	 * @return	void
	 */
	public function __set (String key, value)
	{
		let value = (string)str_replace(["\r", "\n", "\0"], "", (string)value);
		let this->vars[key->lower()] = value;
	}

	/**
	 * initialize
	 * @access	public
	 * @return	void
	 */
	public function initialize () -> void
	{
		let this->to = [];
		let this->cc = [];
		let this->bcc = [];
		let this->subject = "";
		let this->body = "";
		let this->headers = [
			"MIME-Version": "1.0",
			"Message-ID": "",
			"Return-Path": "",
			"Reply-To": "",
			"DKIM-Signature": ""
		];
		let this->vars = [];
	}

	/**
	 * reset session
	 * @access	public
	 * @return	void
	 */
	public function reset () -> void
	{
		this->initialize();
	}

	/**
	 * set "to" address and name
	 * @access	public
	 * @param	string	addr
	 * @param	string	name
	 * @return	<self>
	 */
	public function to (String addr, String name="") ->  <self>
	{
		this->recipient("to", addr, name);
		return this;
	}

	/**
	 * set "cc" address and name
	 * @access	public
	 * @param	string	addr
	 * @param	string	name
	 * @return	<self>
	 */
	public function cc (String addr, String name="") -> <self>
	{
		this->recipient("cc", addr, name);
		return this;
	}

	/**
	 * set "bcc" address and name
	 * @access	public
	 * @param	string	addr
	 * @return	<self>
	 */
	public function bcc (String addr, String name="") -> <self>
	{
		this->recipient("bcc", addr, "");
		return this;
	}

	/**
	 * set "Return-Path" address
	 * @access	public
	 * @param	string	addr
	 * @return	<self>
	 */
	 public function returnPath (String addr) -> <self>
	 {
		this->recipient("Return-Path", addr, "");
		return this;
	 }
 
	 /**
	  * set "Reply-To" address
	  * @access	public
	  * @param	string	addr
	  * @return	<self>
	  */
	 public function replyTo (String addr) -> <self>
	 {
		this->recipient("Reply-To", addr, "");
		return this;
	 }
 
	 /**
	 * set a recipient
	 * @access	private
	 * @param	string	target
	 * @param	string	addr
	 * @param	string	name
	 * @return	void
	 * @throws	\Dew\Mail\Exception
	 */
	private function recipient (const String target, String addr, String name) -> void
	{
		let addr = (string)str_replace(["\n", "\r", "\0"], "", addr->trim());
		let name = (string)str_replace(["\n", "\r", "\0"], "", name->trim());
		if filter_var(addr, FILTER_VALIDATE_EMAIL)===false {
			throw new \Dew\Mail\Exception("\"".addr."\" is invalid.");
		}
		if target=="from" {
			let this->from = ["addr":addr, "name":name];
		} elseif target=="to" {
			let this->to[addr] = ["addr":addr, "name":name];
		} elseif target=="cc" {
			let this->cc[addr] = ["addr":addr, "name":name];
		} elseif target=="bcc" {
			let this->bcc[addr] = ["addr":addr, "name":name];
		} elseif in_array(target, ["Reply-To", "Return-Path"]) {
			let this->headers[target] = (string)sprintf("<%s>", addr);
		}
	}

	/**
	 * set mail header
	 * @access	public
	 * @param	string	key
	 * @param	string	value
	 * @return	<self>
	 */
	public function header (const String key, String value) -> <self>
	{
		let value = (string)str_replace(["\r", "\n", "\0"], "", value);
		if !(bool)in_array(key->lower(), ["to", "cc", "bcc", "from", "subject", "date", "return-path", "reply-to"]) {
			let value = value->trim();
			let this->headers[key] = value;
		}
		return this;
	}

	/**
	 * set subject
	 * @access	public
	 * @param	string	subject
	 * @return	<self>
	 */
	public function subject (String subject) -> <self>
	{
		let this->subject = (string)str_replace(["\r", "\n", "\0"], "", subject->trim());
		return this;
	}

	/**
	 * set body
	 * @access	public
	 * @param	string	body
	 * @return	<self>
	 */
	public function body (const String body) -> <self>
	{
		let this->body = (string)str_replace(["\r\n", "\r"], ["\n", "\n"], body);
		return this;
	}

	/**
	 * MIME encoding
	 * @access	public
	 * @param	string	str
	 * @return	string
	 */
	protected function encode (const String str) -> String
	{
		if !str->length() { return ""; }

		Array chars;
		let chars = (array)unpack("C*", str);
		var c;
		for c in chars {
			if ((c & 0x80) == 0x80) {
				return (string)sprintf("=?UTF-8?B?%s?=", (string)base64_encode(str));
			}
		}
		return str;
	}

	/**
	 * create recipient
	 * @access	protected
	 * @param	Array	addrs
	 * @return	string
	 */
	 protected function createRecipient (Array addrs) -> String
	 {
		 String line="", name="", addr="";
		 var v;

		 for v in addrs {
			 let name = (string)v["name"];
			 let addr = (string)v["addr"];
			 if name->length() {
				 let line .= (string)sprintf("%s <%s>, ", this->encode(name), addr);
			 } else {
				 let line .= (string)sprintf("<%s>, ", addr);
			 }
		 }
		 return trim(line, ", \r\n");
	 }
 
	 /**
	 * create the mail header
	 * @access	protected
	 * @return	array
	 */
	protected function createHeader () -> Array
	{
		String name="", addr="";
		Array headers = [];
		var k, v;

		// Header
		for k, v in this->headers {
			let v = (string)this->encode(v);
			if !strlen(v) { continue; }
			let headers[k] = v;
		}
		let headers["Date"] = date("r");

		// From
		let name = (string)this->from["name"];
		let addr = (string)this->from["addr"];
		if name->length() {
			let headers["From"] = (string)sprintf("%s <%s>", this->encode(name), addr);
		} else {
			let headers["From"] = (string)sprintf("<%s>", addr);
		}
		// Cc
		if count(this->cc) {
			let headers["Cc"] = (string)this->createRecipient(this->cc);
		}
		// Bcc
		if count(this->bcc) {
			let headers["Bcc"] = (string)this->createRecipient(this->bcc);
		}

		return headers;
	}

	/**
	 * create a mail body
	 * @access	protected
	 * @return	string
	 */
	protected function createBody () -> String
	{
		String pattern = "#{{\\s*([a-z_][a-z0-9_]*)\\s*}}#";
		Array matches=[], replaces=[], searches=[];
		if (!preg_match_all(pattern, this->body, matches, PREG_SET_ORDER)) {
			return this->body;
		}

		var m;
		for m in matches {
			let searches[] = (string)m[0];
			let replaces[] = isset this->vars[m[1]] ? (string)this->vars[m[1]] : "";
		}

		return (string)str_replace(searches, replaces, this->body);
	}

	/**
	 * send
	 * @access	public
	 * @return	Boolean
	 */
	public function send () -> Boolean
	{
		String to="", subj="", body="";
		Array headers = [];

		// To
		let to = (string)this->createRecipient(this->to);

		// Header
		let headers = (array)this->createHeader();

		// Subject
		let subj = (string)this->encode(this->subject);

		// Body
		let body = (string)this->createBody();

		return (bool)mail(to, subj, body, headers, "-f".(string)this->from["addr"]);
	}
}
