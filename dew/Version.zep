namespace Dew;
/**
 * Dew\Version
 */
class Version
{
	const MAJOR = 0;
	const MINOR = 1;
	const REVISION = 0;
	const EXTRA = "";

	/**
	 * constructor
	 * @access	public
	 */
	public function __construct ()
	{
	}

	/**
	 * Magic Method
	 * @access	public
	 * @param	string	key
	 * @return	mixed
	 */
	public function __get (String key)
	{
		let key = strtolower(key);
		if key=="major" {
			return self::MAJOR;
		} elseif key=="minor" {
			return self::MINOR;
		} elseif key=="revision" {
			return self::REVISION;
		} elseif key=="extra" {
			return self::EXTRA;
		} elseif key=="id" {
			return this->id();
		} elseif key=="text" {
			return this->text();
		} else {
			return null;
		}
	}

	/**
	 * Magic Method
	 * @access	public
	 * @param	string	key
	 * @param	mixed	value
	 * @return	void
	 */
	public function __set (String key, value)
	{
		return this;
	}

	/**
	 * Magic Method
	 * @access	public
	 * @param	string	key
	 * @param	mixed	value
	 * @return	void
	 */
	public function __toString () -> String
	{
		return this->text();
	}

	/**
	 * get version ID
	 * @access	public
	 * @return	integer
	 */
	public function id () -> Int
	{
		return self::MAJOR*10000 + self::MINOR*100 + self::REVISION;
	}

	/**
	 * get version text
	 * @access	public
	 * @return	string
	 */
	public function text () -> String
	{
		return (string)sprintf("%d.%d.%d%s", self::MAJOR, self::MINOR, self::REVISION, self::EXTRA);
	}
}
