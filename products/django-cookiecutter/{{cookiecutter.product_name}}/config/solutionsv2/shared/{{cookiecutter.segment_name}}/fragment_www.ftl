[#case "www-v1"]

    [#switch _context.Mode ]
        [#case "CELERYWORKER"]
        [#case "CELERYBEAT"]
        [#case "FLOWER" ]
            [#assign command = "/start-" + _context.Mode?lower_case ]
            [#break]
        [#case "TASK"]
            [#assign command = [ "sh" , "-c", "python /app/manage.py $\{APP_TASK_LIST}" ] ]
            [#break]
        [#default]
            [#assign command = "/start"]
    [/#switch]

    [@Command command /]

    [@Policy getSESSendStatement() /]

    [#assign allowedHosts = [ ] +
        (_context.Links["SITE"].State.Attributes.INTERNAL_FQDN)?has_content?then(
            [ _context.Links["SITE"].State.Attributes.INTERNAL_FQDN ],
            []
        ) +
        (_context.Links["SITE"].State.Attributes.FQDN)?has_content?then(
            [ _context.Links["SITE"].State.Attributes.FQDN ],
            []
        )]
        
    [@Settings 
        {
            "DJANGO_ALLOWED_HOSTS" : allowedHosts?has_content?then(
                allowedHosts?join(","),
                "localhost"
            )
        } 
    /]

    [@AltSettings 
        {
            "LOG_LEVEL" : "DJANGO_SENTRY_LOG_LEVEL"
        }
    /]

    {% if cookiecutter.use_celery == "yes" %}[@Settings 
        {
            "CELERY_BROKER_URL" : (_context.Links["redis"].State.Attributes.URL)!""
        }
    /]{% endif %}

    [#break]