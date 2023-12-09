{{/*
Expand the name of the chart.
*/}}
{{- define "zauni_app-be.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zauni_app-be.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zauni_app-be.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "zauni_app-be.labels" -}}
helm.sh/chart: {{ include "zauni_app-be.chart" . }}
{{ include "zauni_app-be.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "zauni_app-be.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zauni_app-be.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
API Backend connection string calculator
*/}}
{{- define "zauni_app-be.env" -}}
- name: MONGO_CONN_STR
  value: mongodb://{{ .Values.mongodb.name }}:27017/{{ .Values.mongodb.databaseName }}
- name: MONGO_USERNAME
  value: {{ .Values.mongodb.username }}
- name: MONGO_PASSWORD
  value: {{ .Values.mongodb.password }}
{{- end }}