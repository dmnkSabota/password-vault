from rest_framework import viewsets, permissions
from rest_framework.filters import SearchFilter

from apps.vault.models import Category, Credential
from apps.vault.serializers import CategorySerializer, CredentialSerializer


class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Category.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class CredentialViewSet(viewsets.ModelViewSet):
    serializer_class = CredentialSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = Credential.objects.filter(user=self.request.user)

        category_id = self.request.query_params.get('category')
        if category_id is not None:
            # Restrict to categories owned by the current user to prevent cross-user inference.
            queryset = queryset.filter(
                category_id=category_id,
                category__user=self.request.user,
            )

        search_query = self.request.query_params.get('q')
        if search_query:
            queryset = queryset.filter(title__icontains=search_query)

        return queryset

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
