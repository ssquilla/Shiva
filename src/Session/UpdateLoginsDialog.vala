namespace session {

    class UpdateLoginsDialog : Gtk.Dialog {


        public string loginValue {get; set;}

        public string passValue {get; set;}

        public GUI.Window window {get; set;}

        private session.LoginManager loginManager {get; set;}

        construct {
 
        }

        public UpdateLoginsDialog(string loginValue, string passValue, GUI.Window window, session.LoginManager loginManager){
            this.loginValue = loginValue;
            this.passValue = passValue;
            this.loginManager = loginManager;
            /*base.with_buttons(
                "Update Logins ?",
                window,
                Gtk.DialogFlags.DESTROY_WITH_PARENT, // | Gtk.DialogFlags.USE_HEADER_BAR, pour mettre le sboutons dans la bar
                "_OK", Gtk.ResponseType.APPLY,
                "_No", Gtk.ResponseType.CLOSE, null
            );*/
            add_button ("_Update", Gtk.ResponseType.APPLY);
            add_button ("_Don't Update", Gtk.ResponseType.CLOSE);
            Gtk.Label label = new Gtk.Label("Would you like to update the logins ?");
            get_content_area ().add(label);
            title = "Update logins ?";
            this.response.connect (on_response);
            show_all();
            present();
        }

        private void on_response (Gtk.Dialog source, int response_id) {
            switch (response_id) {
            case Gtk.ResponseType.HELP:
                // show_help ();
                break;
            case Gtk.ResponseType.APPLY:
                loginManager.updateLoginsIfDifferent(loginValue,passValue);
                destroy();
                break;
            case Gtk.ResponseType.CLOSE:
                destroy ();
                break;
            }
        }
    }

}