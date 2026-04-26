from django.urls import path

from apps.users.views import ProfileView, AccountDeleteView

urlpatterns = [
    path('profile/', ProfileView.as_view(), name='user-profile'),
    path('delete/', AccountDeleteView.as_view(), name='user-delete'),
]
