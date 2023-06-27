 namespace GUI{
    public class HeaderBar : Gtk.HeaderBar {

        private Gtk.Button switchButton;
        public Window main_window { get ; construct; }

        construct {

            set_show_close_button(true);
            switchButton = new Gtk.Button.with_label("Switch");
            switchButton.get_style_context().add_class("suggested-action");
            switchButton.valign = Gtk.Align.CENTER;
            switchButton.clicked.connect( () => {
                triggerSwitchBlock();
            });

            pack_start(switchButton);

            var stack_switcher = new Gtk.StackSwitcher();
    
            stack_switcher.stack = main_window.stack;

            set_custom_title(stack_switcher);


            var menu_button = new Gtk.Button.from_icon_name("open-menu",Gtk.IconSize.LARGE_TOOLBAR);
            menu_button.valign = Gtk.Align.CENTER;
            pack_end(menu_button);


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
            var active = (service.PersistentWebView)main_window.stack.get_visible_child();
            stdout.printf(active.networkName);
            active.tryShiftBlock();
        }

        public Gtk.Stack window_stack { get; construct; }

        public HeaderBar (Window window) {
            Object(main_window : window);
        }
    }
}