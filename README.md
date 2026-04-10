## contenu du .env a remplir ainsi :
```
PRIVATE_KEY=votre_clé_privée_ici 
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/VOTRE_API_KEY 
ETHERSCAN_API_KEY=votre_clé_etherscan_ici 
```

## Puis effectuer les commandes suivantes pour déployer :
### 1. Charger les variables d'environnement
```
source .env
``` 

### 2. Simulation (dry-run) — vérifie que tout est OK sans dépenser de gas 
```
forge script script/DeployToken.s.sol --rpc-url sepolia
```

### 3. Déploiement réel + vérification sur Etherscan 
```
forge script script/DeployToken.s.sol --rpc-url sepolia --broadcast --verify -vvvv
```
