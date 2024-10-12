//
//  Test Math Operations
//  
//
//  Created by Mike Griebling on 28.06.2023.
//

import XCTest
@testable import BigDecimal
import BigInt

class TestOperations: XCTestCase {

    func testMathFunctions() throws {
        let fact1000s =
        """
        40238726007709377354370243392300398571937486421071463254379991042993\
        85123986290205920442084869694048004799886101971960586316668729948085\
        58901323829669944590997424504087073759918823627727188732519779505950\
        99527612087497546249704360141827809464649629105639388743788648733711\
        91810458257836478499770124766328898359557354325131853239584630755574\
        09114262417474349347553428646576611667797396668820291207379143853719\
        58824980812686783837455973174613608537953452422158659320192809087829\
        73084313928444032812315586110369768013573042161687476096758713483120\
        25478589320767169132448426236131412508780208000261683151027341827977\
        70478463586817016436502415369139828126481021309276124489635992870511\
        49649754199093422215668325720808213331861168115536158365469840467089\
        75602900950537616475847728421889679646244945160765353408198901385442\
        48798495995331910172335555660213945039973628075013783761530712776192\
        68490343526252000158885351473316117021039681759215109077880193931781\
        14194545257223865541461062892187960223838971476088506276862967146674\
        69756291123408243920816015378088989396451826324367161676217916890977\
        99119037540312746222899880051954444142820121873617459926429565817466\
        28302955570299024324153181617210465832036786906117260158783520751516\
        28422554026517048330422614397428693306169089796848259012545832716822\
        64580665267699586526822728070757813918581788896522081643483448259932\
        66043367660176999612831860788386150279465955131156552036093988180612\
        13855860030143569452722420634463179746059468257310379008402443243846\
        56572450144028218852524709351906209290231364932734975655139587205596\
        54228749774011413346962715422845862377387538230483865688976461927383\
        81490014076731044664025989949022222176590433990188601856652648506179\
        97023561938970178600408118897299183110211712298459016419210688843871\
        21855646124960798722908519296819372388642614839657382291123125024186\
        64935314397013742853192664987533721894069428143411852015801412334482\
        80150513996942901534830776445690990731524332782882698646027898643211\
        39083506217095002597389863554277196742822248757586765752344220207573\
        63056949882508796892816275384886339690995982628095612145099487170124\
        45164612603790293091208890869420285106401821543994571568059418727489\
        98094254742173582401063677404595741785160829230135358081840096996372\
        52423056085590370062427124341690900415369010593398383577793941097002\
        77534720000000000000000000000000000000000000000000000000000000000000\
        00000000000000000000000000000000000000000000000000000000000000000000\
        00000000000000000000000000000000000000000000000000000000000000000000\
        0000000000000000000000000000000000000000000000000000
        """
        let decimal128 = Rounding.decimal128
        let decimal138 = Rounding(decimal128.mode, decimal128.precision+10)
        
        let pi = BigDecimal.pi(Rounding.decimal128)
        XCTAssertEqual(pi.description,"3.141592653589793238462643383279503")
        XCTAssertEqual(Decimal32.pi.description, "3.141593")
        
        let sqrt1 = BigDecimal.sqrt(BigDecimal.one, decimal128)
        XCTAssertEqual(sqrt1, BigDecimal.one)
        
        let sqrt2 = BigDecimal.sqrt(2, decimal128)
        XCTAssertEqual(sqrt2.description,"1.414213562373095048801688724209698")
        XCTAssertEqual(Decimal32(2).squareRoot().description, "1.414214")
        
        let sqrt10000 = BigDecimal.sqrt(10000, decimal128)
        XCTAssertEqual(sqrt10000, BigDecimal(100))
        
        let cbrt = BigDecimal.root(2, 3, decimal128)
        XCTAssertEqual(cbrt.round(decimal128).description,
                       "1.259921049894873164767210607278228")
        
        let cubed = BigDecimal.pow(cbrt, 3, decimal128)
        XCTAssertEqual(cubed.description, "1.999999999999999999999999999999998")
        
        let bernie = BigDecimal.bernoulli(20, decimal128)
        XCTAssertEqual(bernie.asString(), "-529.1242424242424242424242424242424")
        
        let power = BigDecimal.pow(BigDecimal("1.2"), BigDecimal("1000.5"), decimal128)
        XCTAssertEqual(power.description,
                       "1.662787192208695974282082760752247E+79")
        
        let exp1 = BigDecimal.exp(BigDecimal.one, decimal128)
        XCTAssertEqual(exp1.description, "2.718281828459045235360287471352662")
        
        let fact1000 = BigDecimal.factorial(1000)
        XCTAssertEqual(fact1000.description, fact1000s)
        
        let fact1000limited = BigDecimal.factorial(1000, decimal128)
        XCTAssertEqual(fact1000limited.description,
                       "4.023872600770937735437024339230040E+2567")
        
        let fact = BigDecimal.factorial(BigDecimal(1000), decimal128)
        XCTAssertEqual(fact.description, "4.023872600770937735437024339230040E+2567")

        let gammaHalf = BigDecimal.gamma(BigDecimal("0.5"), decimal128)
        XCTAssertEqual(gammaHalf.description,
                       "1.772453850905516027298167483341145") // sqrt(pi)
        
        let gammaQuarter = BigDecimal.gamma(BigDecimal("0.25"), decimal128)
        XCTAssertEqual(gammaQuarter.description,
                       "3.625609908221908311930685155867672")
        
        let ln10 = BigDecimal.log(BigDecimal.ten, decimal128)
        XCTAssertEqual(ln10.description, "2.302585092994045684017991454684364")
      
        let log2 = BigDecimal.log10(2, decimal128)
        XCTAssertEqual(log2.description, "0.3010299956639811952137388947244930")
        
        let sin1 = BigDecimal.sin(BigDecimal.one, decimal128)
        XCTAssertEqual(sin1.description, "0.8414709848078965066525023216302990")
        
        let cos1 = BigDecimal.cos(BigDecimal.one, decimal128)
        XCTAssertEqual(cos1.description, "0.5403023058681397174009366074429766")
        
        // not sure why this needs more accuracy to give atan = 1
        let tan1 = BigDecimal.tan(BigDecimal.one, decimal138)
        XCTAssertEqual(tan1.round(decimal128).description,
                       "1.557407724654902230506974807458360")
        
        let sinh1 = BigDecimal.sinh(BigDecimal.one, decimal128)
        XCTAssertEqual(sinh1.description, "1.175201193643801456882381850595601")
        
        let cosh1 = BigDecimal.cosh(BigDecimal.one, decimal128)
        XCTAssertEqual(cosh1.description, "1.543080634815243778477905620757062")
        
        let tanh1 = BigDecimal.tanh(BigDecimal.one, decimal128)
        XCTAssertEqual(tanh1.description, "0.7615941559557648881194582826047937")
        
        let one = "1.000000000000000000000000000000000"
        let asin = BigDecimal.asin(sin1, decimal128)
        XCTAssertEqual(asin.description, one)
        let acos = BigDecimal.acos(cos1, decimal128)
        XCTAssertEqual(acos.description, one)
        let atan = BigDecimal.atan(tan1, decimal128)
        XCTAssertEqual(atan.description, one)
        
        let asinh = BigDecimal.asinh(sinh1, decimal128)
        XCTAssertEqual(asinh.description, one)
        let acosh = BigDecimal.acosh(cosh1, decimal128)
        XCTAssertEqual(acosh.description, one)
        let atanh = BigDecimal.atanh(tanh1, decimal128)
        XCTAssertEqual(atanh.description, one)
    }
    
    func testDecimalSizes() throws {
        XCTAssertEqual(MemoryLayout<Decimal32>.size, 4)
        XCTAssertEqual(MemoryLayout<Decimal64>.size, 8)
        XCTAssertEqual(MemoryLayout<Decimal128>.size, 16)
    }

}
