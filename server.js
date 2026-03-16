const express = require("express")
const fs = require("fs")
const bodyParser = require("body-parser")

const app = express()

app.use(bodyParser.json())
app.use(express.static(__dirname))

app.post("/save", (req,res)=>{

let user = req.body.user
let pass = req.body.pass

let data = []

if(fs.existsSync("data.json")){
data = JSON.parse(fs.readFileSync("data.json"))
}

data.push({
user:user,
pass:pass
})

fs.writeFileSync("data.json", JSON.stringify(data,null,2))

res.json({status:"saved"})

})

app.listen(3000, ()=>{
console.log("Server chạy tại http://localhost:3000")
})
