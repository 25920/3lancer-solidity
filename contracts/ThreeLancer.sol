// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ThreeLancer {
    address public deployer;

    constructor() {
        deployer = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == deployer);
        _;
    }

    modifier notOwner() {
        require(msg.sender != deployer);
        _;
    }

    struct Service {
        string name;
        uint256 id;
        string description;
        uint256 fee;
        uint256 intervalInDays;
        bool available;
        address[] pastBuyers;
        string[] comment;
    }

    struct Purchased {
        uint256 id;
        uint256 serviceId;
        address buyer;
        bool delivered;
        string[] data;
    }

    mapping (uint256 => Service) public services;
    mapping (uint256 => Purchased) public records;
    mapping (address => uint256[]) public verified;
    uint256 public serviceAmount;
    uint256 public tradeAmount;

    function isPastBuyer(uint256 _id) public view returns (bool) {
        Service memory service = services[_id];
        bool j=false;
        for (uint t =0;t<service.pastBuyers.length;t++) {
            if (service.pastBuyers[t]==msg.sender) {
                j=true;
                break;
            }
        }
        return j;
    }

    function comment(uint256 _id, string memory _s) notOwner public {
        require(isPastBuyer(_id)==true,"");
        Service storage service = services[_id];
        service.comment.push(_s);
    }

    function verifyUser(address _address, uint256[] memory _ids) public {
        // only allow user to buyer what both of us (msg.sender||deployer and the buyer) aggree on
        require(msg.sender==deployer&&msg.sender!=_address,"");
        if (verified[_address].length==0) {
          verified[_address].push(_ids[0]);
          if (_ids.length>1) {
            for (uint j = 1;j<_ids.length;j++){
              verified[_address].push(_ids[j]);
            }
          }
        } else {
          for (uint j =0;j<_ids.length;j++) {
              verified[_address].push(_ids[j]);
          }
        }
    }

    function ifVerifiedOnId(uint256 _id) notOwner public view returns (bool) {
        uint256[] memory allIds = verified[msg.sender];
        bool k = false;
        for (uint h =0;h<allIds.length;h++){
            if (allIds[h]==_id) {
                k = true;
                break;
            }
        }
        return k;
    }

    function upfrontOneService(uint256 _id) notOwner public payable returns (uint256) {
      require(ifVerifiedOnId(_id)==true,"");
      Service storage newProject = services[_id];
      Purchased storage newRecord = records[tradeAmount];
      newRecord.id = tradeAmount;
      newProject.pastBuyers.push(msg.sender);
      newRecord.delivered=false;
      newRecord.buyer=msg.sender;
      newRecord.serviceId=_id;
      tradeAmount+=1;
      require(msg.value==newProject.fee*50/100,"");
      payable(deployer).transfer(msg.value);
      return tradeAmount-1;
    }

    function upfrontHalfofEachServicesCost(uint256[] memory _serviceIds) notOwner public payable returns (uint256) {
        uint256 cost;
        for (uint f = 0;f < _serviceIds.length;f++) {
            require(ifVerifiedOnId(_serviceIds[f])==true,"");
            Service storage newProject = services[_serviceIds[f]];
            require(newProject.available==true,"");
            Purchased storage newRecord = records[tradeAmount];
            newRecord.id = tradeAmount;
            newProject.pastBuyers.push(msg.sender); // can be duplicate
            newRecord.delivered=false;
            newRecord.buyer=msg.sender;
            newRecord.serviceId=_serviceIds[f];
            cost+=newProject.fee*50/100;
            tradeAmount+=1;
        }
        require(msg.value==cost,"");
        payable(deployer).transfer(msg.value);
        return tradeAmount-_serviceIds.length;
    }

    function updateMappingVerified(uint256 _singleTargetId) notOwner public view returns (uint256[] memory) {
        uint256[] memory map = verified[msg.sender];
        uint256[] memory newMap = new uint256[](map.length-1);
        bool passed = false;
        uint256 c = 0;
        if (newMap.length!=0) {
          for (uint e = 0;e<map.length;e++) {
            if (map[e]!=_singleTargetId) {
              newMap[c]=map[e];
              c+=1;
            } else {
              if (passed==true) {
                newMap[c]=map[e];
                c+=1;
              } else {
                passed = true;
              }
            }
          }
        }
        return newMap;
    }

    function findIndex(uint256 _t) public views returns (uint256) {
      uint256 i = 0;
      for (uint h =0;h<verified[msg.sender].length;h++) {
        if (verified[msg.sender][h]==_t) {
          i = h;
          break;
        }
      }
      return i;
    }

    function payOneServicesSecondHalf(uint256 _id,uint256 _s) notOwner public payable {
        require(ifVerifiedOnId(_s)==true,"");
        Purchased storage oldRecord = records[_id];
        require(msg.sender==oldRecord.buyer,"");
        require(oldRecord.delivered==false,"");
        oldRecord.delivered=true;
        require(msg.value==services[_s].fee*50/100,"");
        payable(deployer).transfer(msg.value);
        verified[msg.sender]=updateMappingVerified(_s);
    }

    function changeDetail(uint256 _id, uint256 _fee,string memory _desp, string memory _title, uint256 _d) onlyOwner public {
        Service storage service = services[_id];
        service.fee=_fee;
        service.intervalInDays=_d;
        service.name=_title;
        service.description=_desp;
    }

    function getServiceBuyerRecords(uint256 _id) onlyOwner view public returns (address[] memory) {
        return services[_id].pastBuyers;
    }

    function deAvailable(uint256 _id) onlyOwner public {
        Service storage service = services[_id];
        require(service.available==true,"");
        service.available=false;
    }

    function reAvailable(uint256 _id) onlyOwner public {
        Service storage service = services[_id];
        require(service.available==false,"");
        service.available=true;
    }

    function createServices(
        Service[] memory _services
    ) onlyOwner public returns (uint256) {
        for (uint y=0;y<_services.length;y++) {
            Service memory temp = _services[y];
            // always make sure the id is correct
            require(
                temp.id==serviceAmount&&temp.available==true,""
            );
            services[serviceAmount]=temp;
            serviceAmount+=1;
        }
        return serviceAmount-_services.length;
    }

    function createService(
      string memory _n,
      string memory _d,
      uint256 _f,
      uint256 _i
    ) onlyOwner public returns (uint256) {
      Service storage newService = services[serviceAmount];
      newService.id=serviceAmount;
      newService.name=_n;
      newService.description=_d;
      newService.fee=_f;
      newService.intervalInDays=_i;
      newService.available=true;
      serviceAmount+=1;
      return serviceAmount-1;
    }

    function addData(
        uint256 _recordId,
        string[] memory _imgs) onlyOwner public {
        Purchased storage record = records[_recordId];
        for (uint h = 0 ; h< _imgs.length;h++) {
            record.data.push(_imgs[h]);
        }
    }

    function allAvailableService(
        ) public view returns (Service[] memory) {
        Service[] memory allEverCreated = new Service[](serviceAmount);
        uint256 f = 0;
        for (uint i=0;i<serviceAmount;i++) {
            Service memory item = services[i];
            if (item.available == true ) {
                allEverCreated[i]=item;
                f+=1;
            }
        }
        if (f == serviceAmount) {
            return allEverCreated;
        } else {
            Service[] memory left = new Service[](f);
            for (uint i  =0;i<f;i++) {
                left[i]=allEverCreated[i];
            }
            return left;
        }
    }

    function allService(
        ) onlyOwner public view returns (Service[] memory) {
        Service[] memory allEverCreated = new Service[](serviceAmount);
        for (uint i  =0;i<serviceAmount;i++) {
            Service memory item = services[i];
            allEverCreated[i]=item;
        }
        return allEverCreated;
    }

    function everyPurchasedData() onlyOwner public view returns (Purchased[] memory) {
        Purchased[] memory allPurchase = new Purchased[](tradeAmount);
        for (uint i  =0;i<tradeAmount;i++) {
            Purchased memory record = records[i];
            allPurchase[i]=record;
        }
        return allPurchase;
    }

    function allPurchaseByServiceId(
        uint256 _id
    ) onlyOwner public view returns (Purchased[] memory) {
        Purchased[] memory allEverBought = new Purchased[](tradeAmount);
        uint256 f = 0;
        for (uint i=0;i<tradeAmount;i++) {
            Purchased memory item = records[i];
            if (item.serviceId == _id ) {
                allEverBought[i]=item;
                f+=1;
            }
        }
        if (f == serviceAmount) {
            return allEverBought;
        } else {
            Purchased[] memory left = new Purchased[](f);
            for (uint i  =0;i<f;i++) {
                left[i]=allEverBought[i];
            }
            return left;
        }
    }

    function allPurchaseByAddress(
        address _address
    ) public view returns (Purchased[] memory) {
        require(msg.sender==_address||msg.sender==deployer,"");
        Purchased[] memory allEverBought = new Purchased[](tradeAmount);
        uint256 f = 0;
        for (uint i=0;i<tradeAmount;i++) {
            Purchased memory item = records[i];
            if (item.buyer == _address ) {
                allEverBought[i]=item;
                f+=1;
            }
        }
        if (f == serviceAmount) {
            return allEverBought;
        } else {
            Purchased[] memory left = new Purchased[](f);
            for (uint i  =0;i<f;i++) {
                left[i]=allEverBought[i];
            }
            return left;
        }
    }
}
