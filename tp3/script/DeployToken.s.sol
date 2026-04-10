// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Script, console} from "forge-std/Script.sol";
import {TokenDeVote} from "../src/TokenDeVote.sol";

/**
 * @title DeployToken
 * @notice Script de déploiement pour le contrat TokenDeVote
 *
 * Usage :
 *   # Simulation (dry-run)
 *   forge script script/DeployToken.s.sol --rpc-url sepolia
 *
 *   # Déploiement réel
 *   forge script script/DeployToken.s.sol --rpc-url sepolia --broadcast
 *
 *   # Avec vérification Etherscan
 *   forge script script/DeployToken.s.sol --rpc-url sepolia --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
 */
contract DeployToken is Script {
    function run() external {
        // Charger la clé privée depuis les variables d'environnement
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Paramètres du contrat TokenDeVote
        string memory tokenName = "Token de Vote";
        string memory tokenSymbol = "TDV";

        console.log("Deploying TokenDeVote contract with:");
        console.log("  Name:", tokenName);
        console.log("  Symbol:", tokenSymbol);

        // Démarrer la diffusion des transactions
        vm.startBroadcast(deployerPrivateKey);

        // Déployer le contrat
        TokenDeVote token = new TokenDeVote(tokenName, tokenSymbol);

        vm.stopBroadcast();

        // Afficher l'adresse du contrat déployé
        console.log("\nTokenDeVote contract deployed at:", address(token));
        console.log("Token Name:", token.name());
        console.log("Token Symbol:", token.symbol());
        console.log("Total Supply:", token.totalSupply());

        console.log("\nDeploy Info:");
        console.log("  Contract Address:", address(token));
        console.log("  Deployer Address:", msg.sender);
    }
}
