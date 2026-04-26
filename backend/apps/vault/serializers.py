from rest_framework import serializers

from apps.vault.models import Category, Credential


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'created_at']
        read_only_fields = ['id', 'created_at']


class CredentialSerializer(serializers.ModelSerializer):
    username = serializers.SerializerMethodField()
    password = serializers.SerializerMethodField()
    url = serializers.SerializerMethodField()
    notes = serializers.SerializerMethodField()

    # Write-only plain-text inputs
    username_input = serializers.CharField(
        write_only=True, required=False, allow_blank=True, source='username'
    )
    password_input = serializers.CharField(
        write_only=True, required=False, allow_blank=True, source='password'
    )
    url_input = serializers.CharField(
        write_only=True, required=False, allow_blank=True, source='url'
    )
    notes_input = serializers.CharField(
        write_only=True, required=False, allow_blank=True, source='notes'
    )

    class Meta:
        model = Credential
        fields = [
            'id',
            'category',
            'title',
            'username',
            'password',
            'url',
            'notes',
            'username_input',
            'password_input',
            'url_input',
            'notes_input',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_username(self, obj):
        return obj.username

    def get_password(self, obj):
        return obj.password

    def get_url(self, obj):
        return obj.url

    def get_notes(self, obj):
        return obj.notes

    def create(self, validated_data):
        username = validated_data.pop('username', '')
        password = validated_data.pop('password', '')
        url = validated_data.pop('url', '')
        notes = validated_data.pop('notes', '')

        credential = Credential(**validated_data)
        credential.username = username
        credential.password = password
        credential.url = url
        credential.notes = notes
        credential.save()
        return credential

    def update(self, instance, validated_data):
        instance.title = validated_data.get('title', instance.title)
        instance.category = validated_data.get('category', instance.category)

        if 'username' in validated_data:
            instance.username = validated_data.get('username')
        if 'password' in validated_data:
            instance.password = validated_data.get('password')
        if 'url' in validated_data:
            instance.url = validated_data.get('url')
        if 'notes' in validated_data:
            instance.notes = validated_data.get('notes')

        instance.save()
        return instance
