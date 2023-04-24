//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.11;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );

/*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }
    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-add-failed");
    }
    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length,"pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-opcode-failed");
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [4252822878758300859123897981450591353533073413197771768651442665752259397132,
             6375614351688725206403948262868962793625744043794305715222011528459656738731],
            [21847035105528745403288232691147584728191162732299865338377159692350059136679,
             10505242626370262277552901082094356697409835680220590971873171140371331206856]
        );
        vk.gamma2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.delta2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.IC = new Pairing.G1Point[](28);
        
        vk.IC[0] = Pairing.G1Point( 
            5377596368460872009410416696905832483591036049855034782009328609985317068423,
            19883245425921716047181191141773748454211550180231826971792315836086127754408
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            21696659052357739837654170904500632358321921016823483384989489390361553080798,
            19542436327457562074564840949067267474626237558458314943257894984494911769820
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            8115450783066252623165989759050059523043267466556426361611826805612756655118,
            4651324874123550647774335282588047085339374177515430880575709874452233554995
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            6337874814116031237762795845928122332381722262785995168476153971809033295468,
            19131673315727370296222913912961278597031342179762067602958391024696104175787
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            13014406905619684009532404393893666538961632119465738595366704000153916195160,
            19381277334436325831649389802636543808353051447845034948254971900172022808769
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            175456472968214332897818501237009699556304979308553233697915144679731677232,
            16220900353280957555662859764754564496237031920233198816849358330958328234388
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            16486157550351096333696926075652052440510330524185879995574394996550690109929,
            12181261169335847749494685107276150259899589434542579517053819236351319665849
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            21690821940191076790084918425153131876373190912476879303360466866964828354097,
            136846284636638621536085508379510019635865796964915551664052722673035802295
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            1671570379623924265350229298374838409356065361611276208719413403333258099239,
            20286779157621822161987635377353484197533104129953346125064730627292570909536
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            1383898176056971286920966979875004335252739060478185003175636447798007225329,
            13375039830381412494303977817181095969252031130793586887237244696216559712953
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            13375373274048034968738880820669210628253691454714241039708381396095534166834,
            13443741868120845823976474836514891046153325288981877495462444776488856568273
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            14355272977016189999112876861943019305020885514838283616648734494270309622621,
            14112000311947623381618825531522248386478844549832796730093390749759156881824
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            2290450936055565834686464890807870232667270444952853828001726701440604411244,
            3017225645841038256672646722075950184574089335951962694333538862185100666943
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            79572306386256890428181221120377749026952773214856453169314695283317102578,
            2184653207015277494529308491845122312019045284620202076037662714464524694322
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            2627564011371131518116131140431593176346559492457569885294807313011475371452,
            16684732276245561484414998750740424888994417880226375882031872437537138236520
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            16044086849168961511832400758466546953813048683007828666689868302115720216871,
            1888201464124006246067154686764838553241407996580060798206942281220216710479
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            2954540751070690699571976145119185803157122762168038423656379526555306833013,
            17053914758842804652861406468281335436247345091900656929526875338245980730479
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            2384794862360844244995209978341305143563904341463806007641712918177915867639,
            16470461064963375467669499146023963046215569222470334699453719679610079776130
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            10601364900410879331613115566981928346366575140393091386294474849400337033627,
            19695518272042145764421916289321326014828787179563181120272914917834210379680
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            14598739592623848022579696988206261137544253953822441578568488821591717969306,
            11622910986929364713803929240070418281645987351653448791369168889185496888703
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            19223756630302053502166739564628135284017864119996500291216718472735805115841,
            12229162422479181926804905989771825666113123957010038042108886114329384060594
        );                                      
        
        vk.IC[21] = Pairing.G1Point( 
            20017104697260588412092344543360163387791503177787313372248500794490858003629,
            590967109716104386000008598293305543076058032920088478006720551282990464692
        );                                      
        
        vk.IC[22] = Pairing.G1Point( 
            1070620298889869960367615322505304630205946474750178391446242368985933675340,
            934527853522085522503768382764030054785077494064557441303121326336706333066
        );                                      
        
        vk.IC[23] = Pairing.G1Point( 
            5206876819700763105181554546480803259910510581350365982962418283937988224953,
            7022094346662066111704954935980150910583542483134732502455168623631017738038
        );                                      
        
        vk.IC[24] = Pairing.G1Point( 
            2146334220169866252692738379086351278718263580902618006510957591991078943428,
            3072740789261256540733113753032295927636820753777991999394384274897637636046
        );                                      
        
        vk.IC[25] = Pairing.G1Point( 
            9152320931939121619322856883895311873773781784274718347055442942470279553209,
            13197295130044802222548304448360183579383859523067665835496349292528245234288
        );                                      
        
        vk.IC[26] = Pairing.G1Point( 
            15984143881094526191873099550932739085069619375115496038784543233101682538366,
            10192664645976026263836498728031579051485169157652968253815820776549944315879
        );                                      
        
        vk.IC[27] = Pairing.G1Point( 
            2052875936741537052518373791673548614025271994955151102789697771087350437418,
            365242033611644082042724219772669019402824333865393345052659560074729206453
        );                                      
        
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    /// @return r  bool true if proof is valid
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[27] memory input
        ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
