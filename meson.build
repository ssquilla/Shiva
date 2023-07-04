project('Shiva', 'vala' , 'c') # com.github.blabla

subdir('data')
subdir('img')


gnome = import('gnome')
gresources = gnome.compile_resources(
    meson.project_name() + '.resources',
    'gresources.xml',
    source_dir: ['ui']
)

executable(
    meson.project_name(),
   'src/Shiva.vala',
   'src/Widgets/Window.vala',
   'src/Widgets/WindowContent.vala',
   'src/Widgets/NavigationBar.vala',
   'src/Session/PersistentWebView.vala',
   'src/Session/LoginManager.vala',
   'src/Session/AutomatizedWebView.vala',
   'src/Session/UpdateLoginsDialog.vala',
   'src/Communication/NotificationManager.vala',
    gresources,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('webkit2gtk-4.1'),
        dependency('libsecret-1'),
    ],
    install:true
)


#meson.add_install_script('meson/post_install.py')
