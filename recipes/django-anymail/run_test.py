import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['anymail', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 

import anymail
