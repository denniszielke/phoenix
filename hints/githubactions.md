


```

SUBSCRIPTION_ID=$(az account show --query id -o tsv) # here enter your subscription id


az ad sp create-for-rbac --name "phoenix-gh" --role owner \
                            --scopes /subscriptions/$SUBSCRIPTION_ID \
                            --sdk-auth
```


