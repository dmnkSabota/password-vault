from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('apps.authentication.urls')),
    path('api/vault/', include('apps.vault.urls')),
    path('api/users/', include('apps.users.urls')),
]
