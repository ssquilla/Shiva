namespace GUI{
    
    public class NetworksButtonsBar : Gtk.ScrolledWindow{
        construct {
            min_content_width = 200;
            //max_content_width = 30;
        }

        public void setWidth(int width){
            min_content_width = width;
        }
    }
    
    public class NavigationBar : Gtk.ActionBar {

        private Gtk.Button switchButton;
        private Gtk.StackSwitcher stackSwitcher;
        private Gtk.Window main_window;
        public NetworksButtonsBar scrollableEmbedder;

        construct {
            switchButton = new Gtk.Button.with_label("Switch");
            switchButton.get_style_context().add_class("suggested-action");
            switchButton.valign = Gtk.Align.CENTER;
            switchButton.clicked.connect( () => {
                triggerSwitchBlock();
            });
            pack_start(switchButton);

            scrollableEmbedder = new NetworksButtonsBar();
            stackSwitcher = new Gtk.StackSwitcher ();

            scrollableEmbedder.add(stackSwitcher);
            set_center_widget(scrollableEmbedder);

            var menu_button = new Gtk.Button.from_icon_name("open-menu",Gtk.IconSize.LARGE_TOOLBAR);
            menu_button.valign = Gtk.Align.CENTER;
            pack_end(menu_button);
            

        }

        public void setStack(WindowContent windowContent){
            stackSwitcher.set_stack(windowContent);
        }

        public void openDialog(){
            var dialog = new Gtk.Dialog.with_buttons(
                "Add a new note",
                main_window,
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

        public Gtk.Button getSwitchButton(){
            return switchButton;
        }

        public void hideSwitchButton(){
            switchButton.hide();
        }

        public void showSwitchButton(){
            switchButton.show();
        }

        public void triggerSwitchBlock(){
            var active = (session.AutomatizedWebView) stackSwitcher.stack.get_visible_child();
            stdout.printf(active.networkName);
            active.tryShiftBlock();
        }
    }

}