# Copyright 2018 Oracle Corporation and/or its affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.

{{/*
Record a validation error (it will get reported later by operator reportValidationErrors)
*/}}
{{- define "operator.recordValidationError" -}}
{{- $scope := index . 0 -}}
{{- $errorMsg := index . 1 -}}
{{- if hasKey $scope "validationErrors" -}}
{{-   $newValidationErrors := cat $scope.validationErrors "\n" $errorMsg -}}
{{-   $ignore := set $scope "validationErrors" $newValidationErrors -}}
{{- else -}}
{{-   $newValidationErrors := cat "\n" $errorMsg -}}
{{-   $ignore := set $scope "validationErrors" $newValidationErrors -}}
{{- end -}}
{{- end -}}

{{/*
Verify that an input value of a specific kind has been specified.
*/}}
{{- define "operator.verifyInputKind" -}}
{{- $requiredKind := index . 0 -}}
{{- $scope := index . 1 -}}
{{- $name := index . 2 -}}
{{- if hasKey $scope $name -}}
{{-   $value := index $scope $name -}}
{{-   $actualKind := kindOf $value -}}
{{-   if eq $requiredKind $actualKind -}}
        true
{{-   else -}}
{{-     $errorMsg := cat "The" $actualKind "property" $name "must be a" $requiredKind "instead." -}}
{{-     include "operator.recordValidationError" (list $scope $errorMsg) -}}
{{-   end -}}
{{- else -}}
{{-   $errorMsg := cat "The" $requiredKind "property" $name "must be specified." -}}
{{-   include "operator.recordValidationError" (list $scope $errorMsg) -}}
{{- end -}}
{{- end -}}

{{/*
Verify that a string input value has been specified
*/}}
{{- define "operator.verifyStringInput" -}}
{{- $args := . -}}
{{- include "operator.verifyInputKind" (prepend $args "string") -}} 
{{- end -}}

{{/*
Verify that a boolean input value has been specified
*/}}
{{- define "operator.verifyBooleanInput" -}}
{{- include "operator.verifyInputKind" (prepend . "bool") -}} 
{{- end -}}

{{/*
Verify that an integer input value has been specified
*/}}
{{- define "operator.verifyIntegerInput" -}}
{{- include "operator.verifyInputKind" (prepend . "float64") -}} 
{{- end -}}

{{/*
Verify that an object input value has been specified
*/}}
{{- define "operator.verifyObjectInput" -}}
{{- include "operator.verifyInputKind" (prepend . "map") -}} 
{{- end -}}

{{/*
Verify that an enum string input value has been specified
*/}}
{{- define "operator.verifyEnumInput" -}}
{{- $scope := index . 0 -}}
{{- $name := index . 1 -}}
{{- $legalValues := index . 2 -}}
{{- if include "operator.verifyStringInput" (list $scope $name) -}}
{{-   $value := index $scope $name -}}
{{-   if has $value $legalValues -}}
      true
{{-   else -}}
{{      $errorMsg := cat "The property" $name "must be one of following values" $legalValues "instead of" $value -}}
{{-     include "operator.recordValidationError" (list $scope $errorMsg) -}}
{{-   end -}}
{{- end -}}
{{- end -}}

{{/*
Report the validation errors that have been found then kill the helm chart install
*/}}
{{- define "operator.reportValidationErrors" -}}
{{- if .validationErrors -}}
{{-   $ignore := required .validationErrors "" -}}
{{- end -}}
{{- end -}}
