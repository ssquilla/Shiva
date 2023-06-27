install_data(
    'window.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0','schemas'),
    rename: meson.project_name() + '.window.gschema.xml'
)


gnome = import('gnome')
gnome.post_install(glib_compile_schemas: true)