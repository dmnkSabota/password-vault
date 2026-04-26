from rest_framework.routers import DefaultRouter

from apps.vault.views import CategoryViewSet, CredentialViewSet

router = DefaultRouter()
router.register('categories', CategoryViewSet, basename='category')
router.register('credentials', CredentialViewSet, basename='credential')

urlpatterns = router.urls
