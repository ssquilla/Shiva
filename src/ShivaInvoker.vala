namespace invoke {
	public class ShivaInvoker : Gtk.Application {

		public ShivaInvoker () {
			Object (application_id: "org.shiva.application", flags : GLib.ApplicationFlags.DEFAULT_FLAGS);
			try{
				register(null);
				this.activate_action ("open-window", null);
			} catch (GLib.Error e){
				stderr.printf("Invoker error : %s \n",e.message);
			}
		}	
	
		public static int main (string[] args) {
			try {
				ShivaInvoker app = new ShivaInvoker ();
				int status = app.run (args);
				return status;
			} catch (Error e) {
				print ("Error: %s\n", e.message);
				return 0;
			}
		}
	}
}
