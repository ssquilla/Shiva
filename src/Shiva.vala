using session;
using communication;

namespace service {
	public class Shiva : Gtk.Application {

		//public bool isPrimary { get; set;}

		public bool isSet {get; set;}
	
		public GUI.Window window{get; set;}
	
		//public NotificationManager notificationManager{get; set;}

		public Array<session.AutomatizedWebView> webViews {get; set;}

		public Shiva () {
			//Object (application_id: "org.shiva.application", flags : GLib.ApplicationFlags.IS_SERVICE);
			Object (application_id: "org.shiva.application", flags : GLib.ApplicationFlags.DEFAULT_FLAGS);
			
			//isPrimary = false;
			set_inactivity_timeout (-1); // never stops
			add_actions ();
			window = null;
			//webViews = new Array<session.AutomatizedWebView>();
			isSet = false;
		}

		public Array<WebViewDescription> getWebViewsDescription(){
			var webViewsDescription = new Array<WebViewDescription>();
			
			/* ====================== discord =========================== */
			// champs de login
			var discordFields = session.LoginFields();
			discordFields.loginField = "uid_5"; //<input class="inputDefault-Ciwd-S input-3O04eu inputField-2RZxdl" id="uid_5" name="email" type="text"
			discordFields.passField = "uid_7"; //<input class="inputDefault-Ciwd-S input-3O04eu" name="password" type="password" 
			// blocks de page
			var discordBlocks = session.PageBlocks();
			discordBlocks.attributes = {"class","class"}; //discordBlocks.attributes = {"data-list-id","class","nodeType"};
			discordBlocks.values = {"sidebar-1tnWFu","container-2cd8Mz"}; //discordBlocks.values = {"guildsnav","sidebar-1tnWFu hasNotice-1s68so","main"};
			// elements a supprimer
			session.DeleteElements? discordDelete = null;
			session.WebViewDescription discord = WebViewDescription("Discord","https://discord.com/login",discordFields,discordBlocks,discordDelete);
			webViewsDescription.append_val(discord);
			/* ====================== messenger ========================= */
			// informations sur les chmpas de connexion
			var messengerFields = session.LoginFields();
			messengerFields.loginField = "email";
			messengerFields.passField = "pass";
			// informations sur les blocks de la page
			var messengerBlocks = session.PageBlocks();
			messengerBlocks.attributes = {"role","role"};
			messengerBlocks.values = {"navigation","main"};
			// elements a supprimer
			session.DeleteElements? messengerDelete = null;

			session.WebViewDescription messenger = WebViewDescription("Messenger","https://messenger.com",messengerFields,messengerBlocks,messengerDelete);
			webViewsDescription.append_val(messenger);
			/* ======================    whats'app    ============================== */
			// champs d'identification
			var whatsAppFields = null;
			// elements a supprimer
			session.DeleteElements whatsappDelete = session.DeleteElements();
			whatsappDelete.attributes = {"data-testid","data-testid","data-testid"};
			whatsappDelete.values = {"drawer-left","drawer-middle","drawer-right"};
			// les blocks de page
			var whatsappBlocks = session.PageBlocks();
			whatsappBlocks.attributes = {"class","id"}; // class = _2Ts6i _3RGKj => block de gauche
			whatsappBlocks.values = {"_2Ts6i _3RGKj","main"}; // class = _2Ts6i _2xAQV => block de droite			

			session.WebViewDescription whatsapp = WebViewDescription("What's app","https://web.whatsapp.com",whatsAppFields,whatsappBlocks,whatsappDelete);
			webViewsDescription.append_val(whatsapp);

			return webViewsDescription;
		}

		public void setupWebViews(){
			webViews = new Array<session.AutomatizedWebView>();
			var webViewsDescription = getWebViewsDescription();
			foreach(session.WebViewDescription description in webViewsDescription){
				stdout.printf("Lauching %s service\n",description.URL);
				if (description.loginFields!=null){
					//stdout.printf("Login fields : %s , %s \n",description.loginFields.loginField,description.loginFields.passField);
				}
				webViews.append_val(new session.AutomatizedWebView(description));
			}
			//notificationManager = new NotificationManager(this,webViews);
		}
	
		public void openWindow(){
			if (window == null){
				stdout.printf("opening window ...\n");
				window = new GUI.Window(this,webViews);
				add_window(window);
				window.setupWindowContent(webViews);
				foreach(session.AutomatizedWebView wb in webViews){
					//wb.tryShiftBlock();
					wb.setWindow(window);
				}
			} else {
				stdout.printf("recovering window ...\n");
			}
			window.show_all();
		}
	
		
		public void add_actions () {
			SimpleAction openAction = new SimpleAction ("open-window", null);
			openAction.activate.connect (() => {
				this.hold ();
				openWindow();
				this.release ();
			});
			this.add_action (openAction);
			/*
			SimpleAction stateful_action = new SimpleAction.stateful ("toggle-action", null, new Variant.boolean (false));
			stateful_action.activate.connect (() => {
				print ("Action %s activated\n", stateful_action.get_name ());
	
				this.hold ();
				Variant state = stateful_action.get_state ();
				bool b = state.get_boolean ();
				stateful_action.set_state (new Variant.boolean (!b));
				print (@"State change $b -> $(!b)\n");
				this.release ();
			});
			this.add_action (stateful_action);*/
		}

		public override void activate () {
			//isPrimary = true;
			//print("Activate\n");
			this.hold ();
			if (!isSet){
				isSet = true;
				//print("Primary app initialising ...\n");
				setupWebViews();
				//notificationManager.allow();
				print ("Primary app initialised\n");
			}
			this.release ();
		}
		
		public void clearLogins(){
			foreach(session.AutomatizedWebView wv in webViews){
				wv.clearLogins();
			}
		}
	
		public static int main (string[] args) {
			try {
				Shiva app = new Shiva ();
				if (args.length > 1) {
					if (args[1] == "--clear") {
						app.clearLogins();
					}
				}
	
				int status = app.run (args);
				return status;
			} catch (Error e) {
				print ("Error: %s\n", e.message);
				return 0;
			}
		}
	}
}
