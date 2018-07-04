find_package(Intltool REQUIRED)

intltool_update_potfile(
  UBUNTU_SDK_DEFAULTS
  GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
)

intltool_install_translations(
  ALL
  GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
)
