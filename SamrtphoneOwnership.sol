// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * A Blockchain-Enabled Framework for Secure and Transparent Smartphone Ownership Tracking
 * Implements: User Registration (Alg.1), Ownership Registration (Alg.2),
 * Ownership Transfer (Alg.3), Theft/Loss Reporting, and CEIR/IMEIDB sync.
 */

contract SmartphoneOwnershipRegistry {

    // ----------------------
    // Roles & Access Control
    // ----------------------

    address public superAdmin; // initial national regulator / consortium lead

    enum Role {
        NONE,
        ADMIN,
        TELCO,
        OEM,
        USER
    }

    mapping(address => Role) public roles;

    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "Not super admin");
        _;
    }

    modifier onlyRole(Role r) {
        require(roles[msg.sender] == r || roles[msg.sender] == Role.ADMIN, "Unauthorized role");
        _;
    }

    constructor() {
        superAdmin = msg.sender;
        roles[msg.sender] = Role.ADMIN;
    }

    event RoleAssigned(address indexed account, Role role);

    function setRole(address account, Role role_) external onlySuperAdmin {
        roles[account] = role_;
        emit RoleAssigned(account, role_);
    }

    // ---------------
    // User Management
    // ---------------

    struct User {
        bytes32 identityHash;  // hash(NID/Passport + salt)
        string offchainRef;    // reference to off-chain KYC record
        bool exists;
    }

    mapping(bytes32 => User) public usersByIdentity; // key: identityHash
    mapping(address => bytes32) public identityOfAddress;

    event UserRegistered(bytes32 indexed identityHash, address indexed account, string offchainRef);

    /**
     * Algorithm 1: User Registration Process (adapted)
     *
     * - PersonalInfo and IdentificationNumber are validated off-chain.
     * - Contract receives a pre-validated identityHash + off-chain reference.
     */
    function registerUser(bytes32 identityHash, string calldata offchainRef, address userAccount)
        external
        onlyRole(Role.TELCO) // or ADMIN; they act as registration authority
    {
        require(identityHash != bytes32(0), "Identity hash required");

        // Step 14: If UserExists(identityNumber) = True then ...
        require(!usersByIdentity[identityHash].exists, "User already exists");

        usersByIdentity[identityHash] = User({
            identityHash: identityHash,
            offchainRef: offchainRef,
            exists: true
        });

        if (userAccount != address(0)) {
            identityOfAddress[userAccount] = identityHash;
            if (roles[userAccount] == Role.NONE) {
                roles[userAccount] = Role.USER;
                emit RoleAssigned(userAccount, Role.USER);
            }
        }

        emit UserRegistered(identityHash, userAccount, offchainRef);
    }

    function userExists(bytes32 identityHash) public view returns (bool) {
        return usersByIdentity[identityHash].exists;
    }

    // -----------------
    // Device Management
    // -----------------

    enum DeviceOwnershipStatus {
        UNSOLD,    // registered under OEM/shop
        OWNED,     // registered under end user
        BLACKLISTED // permanently blocked (e.g., regulatory order)
    }

    enum DeviceSecurityState {
        ACTIVE,
        LOST,
        STOLEN
    }

    struct Device {
        bytes15 imei;                // normalized IMEI
        bytes32 currentOwner;        // identityHash of owner (OEM/shop or user)
        DeviceOwnershipStatus status;
        DeviceSecurityState securityState;
        bool exists;
        string offchainRef;          // optional manufacturing/import record
    }

    mapping(bytes15 => Device) public devices; // IMEI -> Device

    event DeviceRegistered(bytes15 indexed imei, bytes32 indexed ownerId, DeviceOwnershipStatus status, string offchainRef);
    event DeviceStatusUpdated(bytes15 indexed imei, DeviceOwnershipStatus status);
    event DeviceSecurityUpdated(bytes15 indexed imei, DeviceSecurityState state);

    // -----------------------------
    // Ownership Token (logical ERC721)
    // -----------------------------

    // Logical ownership token: maps IMEI to owner identity hash.
    // A full ERC721 could be added if interoperability with wallets is required.

    event OwnershipTokenMinted(bytes15 indexed imei, bytes32 indexed ownerId);
    event OwnershipTransferred(bytes15 indexed imei, bytes32 indexed fromOwner, bytes32 indexed toOwner);

    // ---------------------------
    // Algorithm 2: Ownership Registration
    // ---------------------------

    /**
     * Register a device and initial ownership.
     * - OEM or TELCO/ADMIN can call this.
     * - For factory registration, ownerId is OEM/shop identity; status = UNSOLD.
     * - For direct user registration, status = OWNED.
     */
    function registerDevice(
        bytes15 imei,
        bytes32 ownerId,
        DeviceOwnershipStatus initialStatus,
        string calldata offchainRef
    ) external onlyRole(Role.OEM) {
        require(imei != bytes15(0), "Invalid IMEI");
        require(userExists(ownerId), "Owner identity not found");

        // If IMEI not in Ledger:
        require(!devices[imei].exists, "Device already registered");

        // Register IMEI under OwnerID & generate ownership token (logical)
        devices[imei] = Device({
            imei: imei,
            currentOwner: ownerId,
            status: initialStatus,
            securityState: DeviceSecurityState.ACTIVE,
            exists: true,
            offchainRef: offchainRef
        });

        emit DeviceRegistered(imei, ownerId, initialStatus, offchainRef);
        emit OwnershipTokenMinted(imei, ownerId);
    }

    // ---------------------------
    // Algorithm 3: Ownership Transfer
    // ---------------------------

    struct PendingTransfer {
        bytes15 imei;
        bytes32 fromOwner;
        bytes32 toOwner;
        bool fromApproved;
        bool toApproved;
        bool exists;
    }

    // IMEI -> pending transfer (only one at a time)
    mapping(bytes15 => PendingTransfer) public pendingTransfers;

    event TransferInitiated(bytes15 indexed imei, bytes32 indexed fromOwner, bytes32 indexed toOwner);
    event TransferApproval(bytes15 indexed imei, bytes32 indexed approver, bool approved);
    event TransferCompleted(bytes15 indexed imei, bytes32 indexed fromOwner, bytes32 indexed toOwner);
    event TransferCancelled(bytes15 indexed imei);

    /**
     * Initiate ownership transfer:
     * - Called by TELCO/ADMIN or by the wallet bound to fromOwner identity (off-chain check).
     * - Both parties must exist in the registry.
     */
    function initiateOwnershipTransfer(bytes15 imei, bytes32 fromOwner, bytes32 toOwner)
        external
    {
        require(devices[imei].exists, "Device not registered");
        require(userExists(fromOwner) && userExists(toOwner), "Owner(s) not found");

        Device storage d = devices[imei];
        require(d.currentOwner == fromOwner, "FromOwner not current owner");
        require(d.status == DeviceOwnershipStatus.OWNED || d.status == DeviceOwnershipStatus.UNSOLD, "Transfer not allowed");
        require(d.securityState == DeviceSecurityState.ACTIVE, "Device not in ACTIVE state");
        require(!pendingTransfers[imei].exists, "Transfer already pending");

        pendingTransfers[imei] = PendingTransfer({
            imei: imei,
            fromOwner: fromOwner,
            toOwner: toOwner,
            fromApproved: false,
            toApproved: false,
            exists: true
        });

        emit TransferInitiated(imei, fromOwner, toOwner);
    }

    /**
     * Approve transfer by owner (currentOwner) or new owner.
     * In a real deployment, off-chain KYC & wallet binding ensure only the correct user can approve.
     */
    function approveTransfer(bytes15 imei, bytes32 approverId, bool approve) external {
        PendingTransfer storage pt = pendingTransfers[imei];
        require(pt.exists, "No pending transfer");
        require(approverId == pt.fromOwner || approverId == pt.toOwner, "Not transfer party");

        if (approverId == pt.fromOwner) {
            pt.fromApproved = approve;
        } else {
            pt.toApproved = approve;
        }

        emit TransferApproval(imei, approverId, approve);

        if (!approve) {
            // cancel immediately if either party rejects
            delete pendingTransfers[imei];
            emit TransferCancelled(imei);
            return;
        }

        // If Approved by both:
        if (pt.fromApproved && pt.toApproved) {
            _finalizeTransfer(imei);
        }
    }

    function _finalizeTransfer(bytes15 imei) internal {
        PendingTransfer storage pt = pendingTransfers[imei];
        Device storage d = devices[imei];

        require(d.exists, "Device not registered");
        require(d.currentOwner == pt.fromOwner, "Owner changed during transfer");

        d.currentOwner = pt.toOwner;
        d.status = DeviceOwnershipStatus.OWNED;

        emit OwnershipTransferred(imei, pt.fromOwner, pt.toOwner);
        emit TransferCompleted(imei, pt.fromOwner, pt.toOwner);

        delete pendingTransfers[imei];
    }

    // -----------------------
    // Theft / Loss Management
    // -----------------------

    event TheftOrLossReported(bytes15 indexed imei, bytes32 indexed reporter, DeviceSecurityState state);
    event CEIRSyncRequested(bytes15 indexed imei, DeviceSecurityState state);
    event CEIRSyncConfirmed(bytes15 indexed imei, bool success);

    /**
     * Report device as LOST or STOLEN.
     * - Can be done by TELCO/ADMIN (after verifying report) or by the owner (through their bound address off-chain).
     * - Ownership does not change when security state changes (as in methodology).
     */
    function reportTheftOrLoss(bytes15 imei, bytes32 reporterId, DeviceSecurityState newState)
        external
    {
        require(devices[imei].exists, "Device not registered");
        require(newState == DeviceSecurityState.LOST || newState == DeviceSecurityState.STOLEN, "Invalid state");

        Device storage d = devices[imei];
        // Methodology: "ownership ... will not alter in any way and will stay unchanged" when stolen/lost.[page:1]
        d.securityState = newState;

        emit DeviceSecurityUpdated(imei, newState);
        emit TheftOrLossReported(imei, reporterId, newState);

        // Request sync to CEIR / IMEIDB via off-chain gateway
        emit CEIRSyncRequested(imei, newState);
    }

    /**
     * Mark a device as ACTIVE again (e.g., recovered).
     * Restricted to TELCO/ADMIN to prevent abuse.
     */
    function clearTheftOrLoss(bytes15 imei)
        external
        onlyRole(Role.TELCO)
    {
        require(devices[imei].exists, "Device not registered");

        Device storage d = devices[imei];
        d.securityState = DeviceSecurityState.ACTIVE;

        emit DeviceSecurityUpdated(imei, DeviceSecurityState.ACTIVE);
        emit CEIRSyncRequested(imei, DeviceSecurityState.ACTIVE);
    }

    /**
     * Regulatory function: permanently blacklist a device (e.g., due to fraud).
     */
    function blacklistDevice(bytes15 imei)
        external
        onlyRole(Role.ADMIN)
    {
        require(devices[imei].exists, "Device not registered");

        Device storage d = devices[imei];
        d.status = DeviceOwnershipStatus.BLACKLISTED;

        emit DeviceStatusUpdated(imei, DeviceOwnershipStatus.BLACKLISTED);
        emit CEIRSyncRequested(imei, d.securityState);
    }

    // Called by CEIR/IMEIDB gateway (TELCO role) after off-chain sync.
    function confirmCEIRSync(bytes15 imei, bool success)
        external
        onlyRole(Role.TELCO)
    {
        require(devices[imei].exists, "Device not registered");
        emit CEIRSyncConfirmed(imei, success);
    }

    // ---------------
    // View functions
    // ---------------

    function getDevice(bytes15 imei)
        external
        view
        returns (
            bytes15,
            bytes32,
            DeviceOwnershipStatus,
            DeviceSecurityState,
            bool,
            string memory
        )
    {
        Device memory d = devices[imei];
        return (
            d.imei,
            d.currentOwner,
            d.status,
            d.securityState,
            d.exists,
            d.offchainRef
        );
    }

    function getPendingTransfer(bytes15 imei)
        external
        view
        returns (
            bytes15,
            bytes32,
            bytes32,
            bool,
            bool,
            bool
        )
    {
        PendingTransfer memory pt = pendingTransfers[imei];
        return (
            pt.imei,
            pt.fromOwner,
            pt.toOwner,
            pt.fromApproved,
            pt.toApproved,
            pt.exists
        );
    }
}
