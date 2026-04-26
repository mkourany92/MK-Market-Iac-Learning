# Code Citations

## License: unknown

https://github.com/evgenyb/aks-workshops/blob/d38a3a1494522b1885c0bd5bbd2302be155f6688/03-immutable-aks-infrastructure-with-bicep/labs/lab-02/readme.md

````
Based on the dev file and environment differences, here are both complete parameter files:

---

## `parameters/test/main.parameters.json`

Test mirrors dev — same compute, same SKUs, agent VM enabled:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment":      { "value": "test" },
    "location":         { "value": "eastus" },
    "projectName":      { "value": "mkmarket-web-market" },
    "prefix":           { "value": "mkmarket" },
    "owner":            { "value": "mkmarket-owner" },
    "costCenter":       { "value": "mkmarket-lab" },
    "alertEmail":       { "value": "mkourany@techopsco.com" },
    "deployCompute":    { "value": true },
    "deployAks":        { "value": true },
    "deployAppService": { "value": true },
    "deployAgentVm":    { "value": true },
    "deploySecurity":   { "value": true },
    "computeLocation":  { "value": "eastus" },
    "aksNodeVmSize":    { "value": "Standard_DC2as_v5" },
    "agentVmSize":      { "value": "Standard_DC2as_v5" }
  }
}
````

---

## `parameters/prod/main.parameters.json`

Prod differences:

- `deployAgentVm: false` — no self-hosted CI agents in prod (use hosted agents or separate prod pipeline)
- `aksNodeVmSize`: larger if quota allows — but keeping same `DC2as_v5` since that's what policy allows
- `alertEmail`: should be a real ops/team email not personal

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": { "value": "prod" },
    "location": { "value": "eastus" },
    "projectName": { "value": "mkmarket-web-market" },
    "prefix": { "value": "mkmarket" },
    "owner": { "value": "mkmarket-owner" },
    "costCenter": { "value": "mkmarket-lab" },
    "alertEmail": { "value": "mkourany@techopsco.com" },
    "deployCompute": { "value": true },
    "deployAks": { "value": true },
    "deployAppService": { "value": true },
    "deployAgentVm": { "value": false },
    "deploySecurity": { "value": true },
    "computeLocation": { "value": "eastus" },
    "aksNodeVmSize": { "value": "Standard_DC2as_v5" },
    "agentVmSize": { "value": "Standard_DC2as_v5" }
  }
}
```

---

## Why Each Difference

| Param           | Dev    | Test   | Prod    | Reason              |
| --------------- | ------ | ------ | ------- | ------------------- |
| `deployAgentVm` | `true` | `true` | `false` | Prod uses Microsoft |

```


## License: unknown
https://github.com/evgenyb/aks-workshops/blob/d38a3a1494522b1885c0bd5bbd2302be155f6688/03-immutable-aks-infrastructure-with-bicep/labs/lab-02/readme.md

```

Based on the dev file and environment differences, here are both complete parameter files:

---

## `parameters/test/main.parameters.json`

Test mirrors dev — same compute, same SKUs, agent VM enabled:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": { "value": "test" },
    "location": { "value": "eastus" },
    "projectName": { "value": "mkmarket-web-market" },
    "prefix": { "value": "mkmarket" },
    "owner": { "value": "mkmarket-owner" },
    "costCenter": { "value": "mkmarket-lab" },
    "alertEmail": { "value": "mkourany@techopsco.com" },
    "deployCompute": { "value": true },
    "deployAks": { "value": true },
    "deployAppService": { "value": true },
    "deployAgentVm": { "value": true },
    "deploySecurity": { "value": true },
    "computeLocation": { "value": "eastus" },
    "aksNodeVmSize": { "value": "Standard_DC2as_v5" },
    "agentVmSize": { "value": "Standard_DC2as_v5" }
  }
}
```

---

## `parameters/prod/main.parameters.json`

Prod differences:

- `deployAgentVm: false` — no self-hosted CI agents in prod (use hosted agents or separate prod pipeline)
- `aksNodeVmSize`: larger if quota allows — but keeping same `DC2as_v5` since that's what policy allows
- `alertEmail`: should be a real ops/team email not personal

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": { "value": "prod" },
    "location": { "value": "eastus" },
    "projectName": { "value": "mkmarket-web-market" },
    "prefix": { "value": "mkmarket" },
    "owner": { "value": "mkmarket-owner" },
    "costCenter": { "value": "mkmarket-lab" },
    "alertEmail": { "value": "mkourany@techopsco.com" },
    "deployCompute": { "value": true },
    "deployAks": { "value": true },
    "deployAppService": { "value": true },
    "deployAgentVm": { "value": false },
    "deploySecurity": { "value": true },
    "computeLocation": { "value": "eastus" },
    "aksNodeVmSize": { "value": "Standard_DC2as_v5" },
    "agentVmSize": { "value": "Standard_DC2as_v5" }
  }
}
```

---

## Why Each Difference

| Param           | Dev    | Test   | Prod    | Reason              |
| --------------- | ------ | ------ | ------- | ------------------- |
| `deployAgentVm` | `true` | `true` | `false` | Prod uses Microsoft |

```

```
