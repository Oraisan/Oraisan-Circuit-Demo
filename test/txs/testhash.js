const fmt = require("./fmt")
const main = async () => {
    console.log(await fmt.hash([1, 2]))
};

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });