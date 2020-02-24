if [ "`helm get values --all $(releaseName) | grep -Po 'productionSlot: \K.*'`" == "green" ]; then 
echo "##vso[task.setvariable variable=deploymentslot;isSecret=false;isOutput=true;]blue"
echo "##vso[task.setvariable variable=currentslot;isSecret=false;isOutput=true;]green"
else
echo "##vso[task.setvariable variable=deploymentslot;isSecret=false;isOutput=true;]green"
echo "##vso[task.setvariable variable=currentslot;isSecret=false;isOutput=true;]blue"
fi