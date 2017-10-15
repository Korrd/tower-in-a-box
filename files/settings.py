# AWX settings file

###############################################################################
# MISC PROJECT SETTINGS
###############################################################################

ADMINS = (
   #('Joe Admin', 'joeadmin@example.com'),
)

STATIC_ROOT = '/var/lib/awx/public/static'

PROJECTS_ROOT = '/var/lib/awx/projects'

JOBOUTPUT_ROOT = '/var/lib/awx/job_status'

SECRET_KEY = file('/etc/tower/SECRET_KEY', 'rb').read().strip()

ALLOWED_HOSTS = ['*']

INTERNAL_API_URL = 'http://127.0.0.1:80'

AWX_TASK_ENV['HOME'] = '/var/lib/awx'
AWX_TASK_ENV['USER'] = 'awx'

###############################################################################
# EMAIL SETTINGS
###############################################################################

SERVER_EMAIL = 'root@localhost'
DEFAULT_FROM_EMAIL = 'webmaster@localhost'
EMAIL_SUBJECT_PREFIX = '[AWX] '

EMAIL_HOST = 'localhost'
EMAIL_PORT = 25
EMAIL_HOST_USER = ''
EMAIL_HOST_PASSWORD = ''

AWX_PROOT_ENABLED = False

EMAIL_USE_TLS = False

###############################################################################
# LOGGING SETTINGS
###############################################################################

# Note: This setting may be overridden by database settings.
# This setting is now configured via the Tower API.
# PENDO_TRACKING_STATE = 'detailed'