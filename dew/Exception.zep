namespace Dew;

class Exception extends \Exception
{
	protected sysmsg;

	public function setSystemMessage (String msg)
	{
		let this->sysmsg = msg;
	}

	public function getSystemMessage () -> String
	{
		return this->sysmsg;
	}
}
