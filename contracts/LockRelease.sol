//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "IERC";

contract Locker {

    //TODO: global Locker status (allow locking,.. etc)
    enum Chain { TERRA, POLYGON }
    enum Status { LOCKED, RELEASED, REVERTED }

    struct Transfer {
        bytes32 id,
        address from_addr,
        address to_addr,
        Chain from_chain,
        Chain to_chain,
        uint amt, // integer representation of decimal
        bytes4 from_token, // "usdc" or "ust"
        bytes4 to_token, // "usdc" or "ust
        //status: String // "token_locked", "token_released", "withdrawn_reverted"
        Status status,
        bytes20 lock_tx_hash,
        bytes20 release_tx_hash
        //lock_tx_hash: Addr,
        //release_tx_hash: Addr,
    }

    bytes32[] transfers; // array of ids
    mapping(id => Transfer) transfer_map; // id => Transfer
    address owner;

    bool allow_lock_and_release = true;
    bool allow_revert = true;

    constructor(address token1, address token2) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function _generateNewId(Transfer memory record) internal bytes40 {
        //TODO
        return 0x11111111111111111111111111111111111111111111111111111111111111111111111111111111;
    }

    function _addRecord(
        address from_addr,
        address to_addr,
        Chain from_chain,
        Chain to_chain,
        uint amt,
        bytes4 from_token,
        bytes4 to_token,
        Status status
    ) internal {
        Transfer record = Transfer {
            from_addr: _from_addr,
            to_addr: _to_addr,
            from_chain: _from_chain,
            to_chain: _to_chain,
            amt: _amt,
            from_token: _from_token,
            to_token: _to_token,
            status: _status,
            lock_tx_hash: lock_tx_hash,
            release_tx_hash: release_tx_hash
        }
        record.id = _generateNewId(record);
        transfer_map[id] = newTransfer;
        transfers.add(record.id);
    }

	// transfers usdc from the user to store in contract
	// records it in the Transfers array and updates the state
    function lock(uint amt, address token) {
        IERC(token).transferFrom(msg.sender, address(this), amt);
    }

	// gets the price
	// can use an oracle set up such as https://docs.chain.link/docs/make-a-http-get-request/
	// to ping the url i.e. on coingecko etc to get the usdc/ust pair price
    // TODO: to be implemented
    function get_pancake_swap_usdc_ust_price() internal returns (uint) {
        return 10; 
    }

	// checks to make sure transfer with id exist
	// update the state to add the release_tx_hash
	// checks for the price
	// and release amount get_pancake_swap_usdc_ust_price
    function release(bytes20 transferId) {
        require(transfers[transferId] != 0x0, "no such record exists");
        require(transfers[transferId].status == LOCKED, "only locked tokens can be released");
        transfers[transferId].status = RELEASED;
        IERC(token).transferFrom(address(this), msg.sender, transfers[transferId].amt);
    }

	// only admin can call
	// finds the correct Transfer from the Transfers state
	// updates that Transfer
	// only status can be changed
	// all the other fields are add only, cannot be edited
    function update_state(bytes20 transferId, address from_address, Status _status) onlyOwner {
        require(transfers[transferId] != 0x0, "no such record exists");
        require(transfers[transferId].from_address == from_address, "only locked tokens can be released"); // redundant?
        transfers[transferId].status = _status;
    }

    function update_admin(_admin) external onlyAdmin {
        admin = _admin;
    }

	// prevents new locks or release, only transaction reverts
    function emergency_lock_allow_reverts() external onlyAdmin {
        allow_lock_and_release = false;
    }

	// prevents new locks or release and transaction reverts
    function emergency_lock_disable_reverts() external onlyAdmin {
        allow_lock_and_release = false;
        allow_revert = false;
    }

	// only admin can call
	// withdraws all tokens in the contract to address
    function emergency_withdraw(address emergency_address) onlyAdmin {
        IERC(token0).transferFrom(address(this), emergency_address, token0.balanceOf(address(this)));
        IERC(token1).transferFrom(address(this), emergency_address, token1.balanceOf(address(this)));
    }
}
