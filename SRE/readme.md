### Alerting Rules

global:
  resolve_timeout: 5m
  http_config:
    follow_redirects: true
    enable_http2: true
  smtp_hello: localhost
  smtp_require_tls: true
  pagerduty_url: https://events.pagerduty.com/v2/enqueue
  opsgenie_api_url: https://api.opsgenie.com/
  wechat_api_url: https://qyapi.weixin.qq.com/cgi-bin/
  victorops_api_url: https://alert.victorops.com/integrations/generic/20131114/alert/
  telegram_api_url: https://api.telegram.org
  webex_api_url: https://webexapis.com/v1/messages
route:
  receiver: email-and-slack
  group_by:
  - alertname
  - severity
  continue: false
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
inhibit_rules:
- source_match:
    severity: critical
  target_match:
    severity: warning
  equal:
  - alertname
  - dev
  - instance
receivers:
- name: email-and-slack
  email_configs:
  - send_resolved: true
    to: chiezike16@gmail.com
    from: chiezike16@gmail.com
    hello: localhost
    smarthost: smtp.gmail.com:587
    auth_username: chiezike16@gmail.com
    auth_password: <secret>
    auth_identity: chiezike16@gmail.com
    headers:
      From: chiezike16@gmail.com
      Subject: '{{ template "email.default.subject" . }}'
      To: chiezike16@gmail.com
    html: '{{ template "email.default.html" . }}'
    require_tls: true
  slack_configs:
  - send_resolved: true
    http_config:
      follow_redirects: true
      enable_http2: true
    api_url: <secret>
    channel: '#alerts'
    username: '{{ template "slack.default.username" . }}'
    color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
    title: |-
      [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }} for {{ .CommonLabels.job }}
      {{- if gt (len .CommonLabels) (len .GroupLabels) -}}
        {{" "}}(
        {{- with .CommonLabels.Remove .GroupLabels.Names }}
          {{- range $index, $label := .SortedPairs -}}
            {{ if $index }}, {{ end }}
            {{- $label.Name }}="{{ $label.Value -}}"
          {{- end }}
        {{- end -}}
        )
      {{- end }}
    title_link: '{{ template "slack.default.titlelink" . }}'
    pretext: '{{ template "slack.default.pretext" . }}'
    text: "\n{{ with index .Alerts 0 -}}\n  :chart_with_upwards_trend: *<{{ .GeneratorURL
      }}|Graph>*\n  {{- if .Annotations.runbook }}   :notebook: *<{{ .Annotations.runbook
      }}|Runbook>*{{ end }}\n{{ end }}\n*Alert details*:\n{{ range .Alerts -}}\n  *Alert:*
      {{ .Annotations.title }}{{ if .Labels.severity }} - `{{ .Labels.severity }}`{{
      end }}\n*Description:* {{ .Annotations.description }} *Details:*\n  {{ range
      .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`\n  {{ end }}\n{{ end
      }}\n    "
    short_fields: false
    footer: '{{ template "slack.default.footer" . }}'
    fallback: '{{ template "slack.default.fallback" . }}'
    callback_id: '{{ template "slack.default.callbackid" . }}'
    icon_emoji: '{{ template "slack.default.iconemoji" . }}'
    icon_url: https://avatars3.githubusercontent.com/u/3380462
    link_names: false
templates: []