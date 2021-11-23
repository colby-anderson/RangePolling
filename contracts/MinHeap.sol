pragma solidity ^0.6.0;
/// @title Implementation of a min-heap
/// @author Adrián Calvo (https://github.com/adrianclv)
contract MinHeap{
    constructor () public {}
    // Maximum number of elements allowed in the heap
    uint private constant MAX_ELEMS = 100;
    uint[101] elems;
    uint numElems;

    function inn(uint elem) internal returns (bool) {
        for (uint i = 0; i < elems.length; i++) {
            if (elems[i] == elem) {
                return true;
            }
        }
        return false;
    }

    /// @notice Inserts the element `elem` in the heap
    /// @param elem Element to be inserted
    function insert(uint elem) external {
        if (inn(elem)) {
            return;
        }
        numElems++;
        elems[numElems] = elem;

        shiftUp(numElems);
    }

    /// @notice Deletes the element with the minimum value
    function pop() external returns (uint) {
        uint val = min();

        deletePos(1);
        return val;
    }

    /// @notice Deletes the element in the position `pos`
    /// @param pos Position of the element to be deleted
    function deletePos(uint pos) internal {
//        require (numElems < pos);

        elems[pos] = elems[numElems];
        delete elems[numElems];
        numElems--;

        shiftDown(pos);
    }

    /// @notice Returns the element with the minimum value
    /// @return The element with the minimum value
    function min() view public returns(uint){
//        require (numElems == 0);

        return elems[1];
    }

    /// @notice Checks if the heap is empty
    /// @return True if there are no elements in the heap
    function isEmpty() view external returns(bool){

        return (numElems == 0);
    }

    /* Private functions */

    // Move a element up in the tree
    // Used to restore heap condition after insertion
    function shiftUp(uint pos) private{
        uint copy = elems[pos];

        while(pos != 1 && copy < elems[pos/2]){
            elems[pos] = elems[pos/2];
            pos = pos/2;
        }
        elems[pos] = copy;
    }

    // Move a element down in the tree
    // Used to restore heap condition after deletion
    function shiftDown(uint pos) private{
        uint copy = elems[pos];
        bool isHeap = false;

        uint sibling = pos*2;
        while(sibling <= numElems && !isHeap){
            if(sibling != numElems && elems[sibling+1] < elems[sibling])
                sibling++;
            if(elems[sibling] < copy){
                elems[pos] = elems[sibling];
                pos = sibling;
                sibling = pos*2;
            }else{
                isHeap = true;
            }
        }
        elems[pos] = copy;
    }
}
