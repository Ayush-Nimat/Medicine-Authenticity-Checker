pragma solidity ^0.8.20;

contract MedicineAuthenticityChecker {

    // Structure to store medicine information
    struct Medicine {
        string name;
        string batchNumber;
        string manufacturer;
        uint256 manufacturingDate;
        uint256 expiryDate;
        bytes32 medicineHash;
        bool registered;
    }

    // Mapping: medicine hash => medicine details
    mapping(bytes32 => Medicine) public medicines;

    // Array to store all medicine hashes
    bytes32[] public medicineList;

    // Register a new medicine
    function registerMedicine(
        string memory _name,
        string memory _batchNumber,
        string memory _manufacturer,
        uint256 _manufacturingDate,
        uint256 _expiryDate
    ) public returns (bytes32) {

        // Expiry date must be after manufacturing date
        require(
            _expiryDate > _manufacturingDate,
            "Expiry date must be after manufacturing date"
        );

        // Generate cryptographic hash
        bytes32 medicineHash = keccak256(
            abi.encodePacked(
                _name,
                _batchNumber,
                _manufacturer,
                _manufacturingDate,
                _expiryDate
            )
        );

        // Check if medicine already exists
        require(
            !medicines[medicineHash].registered,
            "Medicine already registered"
        );

        // Store medicine details
        medicines[medicineHash] = Medicine({
            name: _name,
            batchNumber: _batchNumber,
            manufacturer: _manufacturer,
            manufacturingDate: _manufacturingDate,
            expiryDate: _expiryDate,
            medicineHash: medicineHash,
            registered: true
        });

        // Add hash to array
        medicineList.push(medicineHash);

        return medicineHash;
    }

    // Verify medicine authenticity
    function verifyMedicine(
        string memory _name,
        string memory _batchNumber,
        string memory _manufacturer,
        uint256 _manufacturingDate,
        uint256 _expiryDate
    ) public view returns (bool, bytes32) {

        // Generate hash again
        bytes32 medicineHash = keccak256(
            abi.encodePacked(
                _name,
                _batchNumber,
                _manufacturer,
                _manufacturingDate,
                _expiryDate
            )
        );

        // Check whether medicine is registered
        bool isAuthentic = medicines[medicineHash].registered;

        return (isAuthentic, medicineHash);
    }

    // Get medicine details using hash
    function getMedicine(bytes32 _medicineHash)
        public
        view
        returns (
            string memory name,
            string memory batchNumber,
            string memory manufacturer,
            uint256 manufacturingDate,
            uint256 expiryDate,
            bytes32 medicineHash,
            bool registered
        )
    {
        Medicine memory medicine = medicines[_medicineHash];

        require(
            medicine.registered,
            "Medicine not found"
        );

        return (
            medicine.name,
            medicine.batchNumber,
            medicine.manufacturer,
            medicine.manufacturingDate,
            medicine.expiryDate,
            medicine.medicineHash,
            medicine.registered
        );
    }

    // Get total number of registered medicines
    function getMedicineCount()
        public
        view
        returns (uint256)
    {
        return medicineList.length;
    }

    // Get all medicine hashes
    function getAllMedicineHashes()
        public
        view
        returns (bytes32[] memory)
    {
        return medicineList;
    }

    // Get all medicines using a loop
    function getAllMedicines()
        public
        view
        returns (
            string[] memory names,
            string[] memory batchNumbers,
            string[] memory manufacturers,
            bytes32[] memory hashes
        )
    {
        uint256 count = medicineList.length;

        names = new string[](count);
        batchNumbers = new string[](count);
        manufacturers = new string[](count);
        hashes = new bytes32[](count);

        // Loop through all registered medicines
        for (uint256 i = 0; i < count; i++) {

            bytes32 hash = medicineList[i];

            names[i] = medicines[hash].name;
            batchNumbers[i] = medicines[hash].batchNumber;
            manufacturers[i] = medicines[hash].manufacturer;
            hashes[i] = medicines[hash].medicineHash;
        }

        return (
            names,
            batchNumbers,
            manufacturers,
            hashes
        );
    }
}
