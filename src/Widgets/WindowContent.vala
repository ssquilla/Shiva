 namespace GUI{
    public class WindowContent : Gtk.Stack {
       
        construct {
            
        }

        public GUI.Window getWindow(){
            return (GUI.Window) parent;
        } 

        public void openDialog(){
            var dialog = new Gtk.Dialog.with_buttons(
                "Add a new note",
                getWindow(),
                Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT, // | Gtk.DialogFlags.USE_HEADER_BAR, pour mettre le sboutons dans la bar
                "Custom button", 1,
                "Second button", 2, null
            );

            var label = new Gtk.Label("this is the content");
            var content_area = dialog.get_content_area();
            content_area.add(label);

            dialog.show_all();
            dialog.present();
        }
    }
}