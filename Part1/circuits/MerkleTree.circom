pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template PoseidonHashT3() {
    var nInputs = 2;
    signal input inputs[nInputs];
    signal output out;

    component hasher = Poseidon(nInputs);
    for (var i = 0; i < nInputs; i ++) {
        hasher.inputs[i] <== inputs[i];
    }
    out <== hasher.out;
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var m = 2**n;
    var offset = 0;
    component hasher[(2**n)-1];
    var h[2 * m - 1];

    for(var i=0;i < m; i++){
        h[i] = leaves[i];
    }
    
    while(m>0) {
        for (var i = 0; i < m-1; i+=2) {
            hasher[i] = PoseidonHashT3();
            hasher[i].inputs[0] <== leaves[offset + i];
            hasher[i].inputs[1] <== leaves[offset + i + 1];
            h[m+i] = hasher[i].out;
        }
        offset += m;
        m = m / 2;
    }

    root <== h[2 * m-2];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    var hash = leaf;
    component hasher[n];
    component mux[n][2];

    for (var i = 0; i < n -1; i++) {
        
        mux[i][0] = Mux1();
        mux[i][1] = Mux1();

        mux[i][0].c[0] <== path_elements[i];
        mux[i][0].c[1] <== path_elements[i+1];
        mux[i][0].s <== path_index[i];

        mux[i][1].c[0] <== path_elements[i];
        mux[i][1].c[1] <== path_elements[i+1];
        mux[i][1].s <== path_index[i+1];

        hasher[i] = PoseidonHashT3();
        hasher[i].inputs[0] <== mux[i][0].out;
        hasher[i].inputs[1] <== mux[i][1].out;
        hash = hasher[i].out;
    }

    root <== hash;

}