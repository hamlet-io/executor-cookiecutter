# {{cookiecutter.product_name}} CodeOnTap CMDB

This solution is designed to host a django based application created using the [django cookiecutter template(https://cookiecutter-django.readthedocs.io/en/latest/index.html)]

## To Do

A couple of changes are required for full support

### Code Changes

- [ ] Add AWS packages to `requirements/base`

   ```python
   # For KMS / env decryption
    boto3>=1.7.72,<2
    awscli>=1.15.76,<2
    ```

- [ ] Add KMS decryption support for celery flower
   `compose/production/django/flower/start` add above flower command

   ```bash
    CELERY_FLOWER_USER="${CELERY_FLOWER_USER:-"admin"}"
    CELERY_FLOWER_PASSWORD_ENCRYPTED="${CELERY_FLOWER_PASSWORD_ENCRYPTED:-"false"}"

    if [[ "${CELERY_FLOWER_PASSWORD_ENCRYPTED}" == "true" ]]; then
        echo "${CELERY_FLOWER_PASSWORD#"base64:"}" | base64 -d > "/tmp/cipher.blob"
        CELERY_FLOWER_PASSWORD="$(aws --region "${AWS_REGION}" kms decrypt --ciphertext-blob "fileb:///tmp/cipher.blob" --output text --query Plaintext | base64 -d )"

        if [[ -z "${CELERY_FLOWER_PASSWORD}" ]]; then
            echo "Celery Password was supposed to be encrypted but we couldn't decrypt it"
            exit 255
        fi
    fi

    export FLOWER_BASIC_AUTH="${CELERY_FLOWER_USER}:${CELERY_FLOWER_PASSWORD}"
    ```

- [ ] Add AWS KMS decryption of environment variables
   `settings/kms.py` add the following file

   ```python
    import os
    import base64
    import logging

    import boto3

    BASE64_PREFIX = 'base64:'
    AWS_REGION = os.environ.get('AWS_REGION', None)

    def decrypt_kms_data(encrypted_data):
        """Decrypt KMS encoded data."""
        if not AWS_REGION:
            return

        kms = boto3.client('kms', region_name=AWS_REGION)

        decrypted = kms.decrypt(CiphertextBlob=encrypted_data)

        if decrypted.get('KeyId'):
            # Decryption succeed
            decrypted_value = decrypted.get('Plaintext', '')
            if isinstance(decrypted_value, bytes):
                decrypted_value = decrypted_value.decode('utf-8')
            return decrypted_value


    def string_or_b64kms(value):
        """Check if value is base64 encoded - if yes, decode it using KMS."""
        if not value:
            return value

        try:
            # Check if environment value base64 encoded
            if isinstance(value, (str, bytes)) and value.startswith(BASE64_PREFIX):
                value = value[len(BASE64_PREFIX):]
                # If yes, decode it using AWS KMS
                data = base64.b64decode(value)
                decrypted_value = decrypt_kms_data(data)

                # If decryption succeed, use it
                if decrypted_value:
                    value = decrypted_value
        except Exception as e:
            logging.exception(e)
        return value
    ```

- [ ] Use anymail AWS SES for email backend
   `settings/production.py` replace the email section with the following

   ```python
    EMAIL_BACKEND = 'anymail.backends.amazon_ses.EmailBackend'
    # https://anymail.readthedocs.io/en/stable/installation/#anymail-settings-reference
    ANYMAIL = {
        'AMAZON_SES_CLIENT_PARAMS': {
            'region_name': env('SES_REGION', default='us-east-1')
        }
    }
    ```

- [ ] AWS ALB load balancer Support
    `settings/production.py` in the GENERAL section under allowed hosts add

    ```python 
    # AWS Load balancers perform healthchecks using the host header set to the instance IP
    EC2_PRIVATE_IP = None
    try:
        EC2_PRIVATE_IP = requests.get('http://169.254.169.254/latest/meta-data/local-ipv4', timeout=0.01).text
    except requests.exceptions.RequestException:
        pass

    if EC2_PRIVATE_IP:
        ALLOWED_HOSTS.append(EC2_PRIVATE_IP)

    # So that the healthcheck works without being redirect to https
    SECURE_REDIRECT_EXEMPT = [
        r'^healthcheck'
    ]
    ```

### CMDB Changes

These steps should be completed once you have deployed the baseline and cmk components for your environment using CodeOnTap 

- [ ] Generate and encrypt `DJANGO_SECRET_KEY` in credentials.json in `infrastructure/operations/{{cookiecutter.environment_name}}/{{cookiecutter.segment_name}}/application-app-www/credentials.json`
- [ ] Generate and encrypt `CELERY_FLOWER_PASSWORD` in `infrastructure/operations/{{cookiecutter.environment_name}}/{{cookiecutter.segment_name}}/www-v1-flower/credentials.json`