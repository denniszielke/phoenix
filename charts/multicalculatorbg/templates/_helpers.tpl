{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "multicalculatorblue.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 61 | trimSuffix "-b" -}}
{{- end -}}

{{- define "multicalculatorgreen.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 61 | trimSuffix "-g" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "multicalculatorblue.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 61 | trimSuffix "-b" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 61 | trimSuffix "-b" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 61 | trimSuffix "-b" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "multicalculatorgreen.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 61 | trimSuffix "-g" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 61 | trimSuffix "-g" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 61 | trimSuffix "-g" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "multicalculatorbg.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "multicalculatorbg.labels" -}}
helm.sh/chart: {{ include "multicalculatorbg.chart" . }}
{{ include "multicalculatorbg.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "multicalculatorv3.selectorLabels" -}}
app.kubernetes.io/name: {{ include "multicalculatorv3.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "multicalculatorv3.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "multicalculatorv3.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
