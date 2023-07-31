
using session;

namespace GUI{
    
    [GtkTemplate (ui = "/ui/Window.ui")]
    public class Window : Gtk.ApplicationWindow {

        public Window (service.Shiva app, Array<AutomatizedWebView> webViews) {
            Object(
                application: app
            );          
            //show.connect(setScrollableWidth);


            configure_event.connect ((event) => {
                int percent = 50;
                int finalWidth = (int) event.width*percent/100;
                navigationBar.scrollableEmbedder.setWidth(finalWidth);
                return false;
            });

            setupWindowContent(webViews);
            show_all();
        }   

        public GLib.Settings settings;

        [GtkChild]
        NavigationBar navigationBar;
        [GtkChild]
        WindowContent windowContent;        

        construct{
            window_position = Gtk.WindowPosition.CENTER;
            
            loadSettings();
            //fullscreen();
            delete_event.connect(e => {
                saveSettings();
                return hide_on_delete();
            });
            
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/data/gtk3.css");
            Gtk.StyleContext.add_provider_for_screen (get_screen (), provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            Gdk.Pixbuf icon = new Gdk.Pixbuf.from_file ("img/app_icon.png");
            set_icon(icon);
        }

        public void loadSettings(){
            settings = new GLib.Settings("window-position");
            move(settings.get_int("pos-x"),settings.get_int("pos-y"));
            resize(settings.get_int("window-width"),settings.get_int("window-height"));
        }

        public WebKit.WebView getActiveWebView(){
            return (WebKit.WebView) windowContent.get_visible_child ();
        }

        public void setupWindowContent(Array<AutomatizedWebView> webViews){
            foreach(session.AutomatizedWebView webView in webViews){
                var title = webView.networkName + " : homepage";
                var name = webView.networkName[:1];
                windowContent.add_titled(webView,title,name);
            }
            navigationBar.setStack(windowContent);
            
        }

        public void saveSettings(){
            int x,y, width, height;
            get_size(out width, out height);
            get_position(out x, out y);
            settings.set_int("pos-x",x);
            settings.set_int("pos-y",y);
            settings.set_int("window-width",width);
            settings.set_int("window-height",height);
        }
    }
}
