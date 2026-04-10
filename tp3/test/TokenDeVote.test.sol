// test/TokenDeVote.t.sol
pragma solidity ^0.8.33;
import {Test} from "forge-std/Test.sol";
import {TokenDeVote} from "../src/TokenDeVote.sol";

contract TokenDeVoteTest is Test {
    TokenDeVote token;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);
    address carol = address(0xCA701);

    function setUp() public {
        // Déployer le token de vote
        token = new TokenDeVote("Token de Vote", "TDV");
    }
    
    // ── Tests de base ──
    
    function test_InitialSupply() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(address(this)), 0);
    }
    
    function test_Metadata() public {
        assertEq(token.name(), "Token de Vote");
        assertEq(token.symbol(), "TDV");
        assertEq(token.decimals(), 0);
    }
    
    // ── Tests de claimToken() ──
    
    function test_ClaimToken() public {
        vm.prank(alice);
        bool success = token.claimToken();
        assertTrue(success);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.hasClaimed(alice), true);
        assertEq(token.totalSupply(), 1);
    }
    
    function test_ClaimToken_RevertDoubleClaim() public {
        vm.prank(alice);
        token.claimToken();
        
        vm.prank(alice);
        vm.expectRevert();
        token.claimToken();
    }
    
    function test_ClaimToken_EmitEvent() public {
        vm.expectEmit(true, true, false, true);
        emit TokenDeVote.Transfer(address(0), alice, 1);
        
        vm.prank(alice);
        token.claimToken();
    }
    
    // ── Tests de vote() ──
    
    function test_Vote() public {
        // Alice et Bob réclament leurs tokens
        vm.prank(alice);
        token.claimToken();
        vm.prank(bob);
        token.claimToken();
        
        // Alice vote pour Bob
        vm.prank(alice);
        bool success = token.vote(bob);
        assertTrue(success);
        
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 2); // Son token + celui d'Alice
        assertEq(token.hasVoted(alice), true);
        assertEq(token.totalSupply(), 2);
    }
    
    function test_Vote_RevertTwice() public {
        vm.prank(alice);
        token.claimToken();
        vm.prank(bob);
        token.claimToken();
        
        // Alice vote pour Bob
        vm.prank(alice);
        token.vote(bob);
        
        // Alice essaye de voter à nouveau
        vm.prank(alice);
        vm.expectRevert("Already voted");
        token.vote(bob);
    }
    
    function test_Vote_RevertVoteForYourself() public {
        vm.prank(alice);
        token.claimToken();
        
        vm.prank(alice);
        vm.expectRevert("Cannot vote for yourself");
        token.vote(alice);
    }
    
    function test_Vote_RevertVoteForZeroAddress() public {
        vm.prank(alice);
        token.claimToken();
        
        vm.prank(alice);
        vm.expectRevert("Vote for zero address");
        token.vote(address(0));
    }
    
    function test_Vote_RevertNoToken() public {
        // Carol n'a pas réclaimé de token
        vm.prank(alice);
        token.claimToken();
        
        // Carol essaye de voter sans token
        vm.prank(carol);
        vm.expectRevert("No voting token");
        token.vote(alice);
    }
    
    function test_Vote_EmitEvent() public {
        vm.prank(alice);
        token.claimToken();
        vm.prank(bob);
        token.claimToken();
        
        vm.expectEmit(true, true, false, true);
        emit TokenDeVote.Transfer(alice, bob, 1);
        
        vm.prank(alice);
        token.vote(bob);
    }
    
    // ── Tests des fonctions ERC20 (transfer, approve, etc.) ──
    
    function test_Transfer() public {
        vm.prank(alice);
        token.claimToken();
        vm.prank(bob);
        token.claimToken();
        
        // Alice transfère son token à Carol
        vm.prank(alice);
        bool success = token.transfer(carol, 1);
        assertTrue(success);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(carol), 1);
    }
    
    function test_Transfer_RevertSoldeInsuffisant() public {
        vm.prank(alice);
        token.claimToken();
        
        vm.prank(alice);
        vm.expectRevert("Insufficient balance");
        token.transfer(bob, 2);
    }
    
    function test_Transfer_RevertAddressZero() public {
        vm.prank(alice);
        token.claimToken();
        
        vm.prank(alice);
        vm.expectRevert("Transfer to zero address");
        token.transfer(address(0), 1);
    }
    
    function test_Approve() public {
        vm.prank(alice);
        bool success = token.approve(bob, 1);
        assertTrue(success);
        assertEq(token.allowance(alice, bob), 1);
    }
    
    function test_TransferFrom() public {
        vm.prank(alice);
        token.claimToken();
        
        vm.prank(alice);
        token.approve(bob, 1);
        
        vm.prank(bob);
        bool success = token.transferFrom(alice, carol, 1);
        assertTrue(success);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(carol), 1);
        assertEq(token.allowance(alice, bob), 0);
    }
    
    // ── Tests d'invariants ──
    
    function test_Invariant_TotalSupply() public {
        vm.prank(alice);
        token.claimToken();
        vm.prank(bob);
        token.claimToken();
        
        assertEq(
            token.balanceOf(alice) + token.balanceOf(bob),
            token.totalSupply()
        );
    }
    
    function test_Scenario_MultipleVotes() public {
        // Trois utilisateurs réclament leurs tokens
        vm.prank(alice);
        token.claimToken();
        vm.prank(bob);
        token.claimToken();
        vm.prank(carol);
        token.claimToken();
        
        // Alice et Bob votent pour Carol
        vm.prank(alice);
        token.vote(carol);
        assertEq(token.balanceOf(carol), 2);
        
        vm.prank(bob);
        token.vote(carol);
        assertEq(token.balanceOf(carol), 3);
        
        // Vérifier que totalSupply est conservé
        assertEq(token.totalSupply(), 3);
    }
}