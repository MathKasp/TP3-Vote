// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/**
 * @title MyFirstToken
 * @notice Implémentation ERC20 from scratch à des fins pédagogiques
 *
 * Invariants à maintenir :
 * - La somme de tous les balances == totalSupply
 * - Un transfert ne peut jamais créer ou détruire des tokens
 * - allowance diminue correctement après un transferFrom
 */
contract MyFirstToken {
    // --- Métadonnées ---
    string public name;
    string public symbol;
    uint8 public decimals;
    // --- État ERC20 ---
    uint256 public totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @notice Constructeur — mint la supply initiale au déployeur
     * @param _name Nom du token (ex: "My First Token")
     * @param _symbol Symbole du token (ex: "MFT")
     * @param _initialSupply Nombre de tokens à créer (en unités, pas en wei)
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        // Mint la supply initiale au déployeur
        _mint(msg.sender, _initialSupply * 10 ** decimals);
    }

    // ================================================================
    // Fonctions ERC20 à implémenter
    // ================================================================
    /**
     * @notice Retourne le solde d'une adresse
     */
    function balanceOf(address account) external view returns (uint256) {
        // TODO: retourner le solde de 'account'
        return _balances[account];
    }

    /** 
     * @notice Transfère 'amount' tokens vers 'to' 
     * @dev Doit revert si le solde est insuffisant 
     * @dev Doit émettre un event Transfer 
     * @dev Doit retourner true en cas de succès 

     */
    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /** 
     * @notice Retourne la quantité que 'spender' peut dépenser au nom de 
'owner' 
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        // TODO: retourner l'allowance
        return _allowances[owner][spender];
    }

    /**
     * @notice Autorise 'spender' à dépenser 'amount' tokens
     * @dev Doit émettre un event Approval
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        // TODO: implémenter l'approbation
        // Mettre à jour _allowances[msg.sender][spender]
        // Émettre Approval(msg.sender, spender, amount)
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Transfère 'amount' tokens de 'from' vers 'to'
     * @dev Nécessite que msg.sender ait une allowance suffisante
     * @dev Doit décrémenter l'allowance
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        // TODO: implémenter transferFrom
        // Vérifications :
        // - _allowances[from][msg.sender] >= amount
        // - from != address(0) et to != address(0)
        // - _balances[from] >= amount
        // Décrémenter l'allowance
        // Mettre à jour les soldes
        // Émettre Transfer(from, to, amount)
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(_balances[from] >= amount, "Insufficient balance");
        require(
            _allowances[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    // ================================================================
    // Fonctions internes
    // ================================================================
    /**
     * @notice Crée 'amount' tokens et les assigne à 'to'
     * @dev Augmente totalSupply
     */
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");
        totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    /**
     * @notice Détruit 'amount' tokens du compte 'from'
     * @dev Diminue totalSupply
     */
    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "Burn from zero address");
        require(_balances[from] >= amount, "Burn amount exceeds balance");
        _balances[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}