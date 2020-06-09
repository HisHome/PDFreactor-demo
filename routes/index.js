const router = require('koa-router')()
const fs = require('fs');
const path = require('path');
var template = require('art-template');

var exercieData = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../public/exercise.json")));

const PDFreactor = require("../public/PDFreactor_10_1_10722_13_webservice_clients/nodejs/lib/PDFreactor.js");
// Create new PDFreactor instance
// var pdfReactor = new PDFreactor("https://cloud.pdfreactor.com/service/rest");
var pdfReactor = new PDFreactor();
var config = {
    document: "<h1>模板</h1>"
};

router.get('/', async (ctx, next) => {
    // let tmp = fs.readFileSync(path.resolve(__dirname, '../views/new.html'), 'utf-8')
    // let tmp = template(path.resolve(__dirname, '../views/tmp.html'), {exercieData, arr:[1,2,3]})
    let tmp = template(path.resolve(__dirname, '../views/studentTmp.html'), {exercieData, arr:[1,2,3]})
    // let tmp = template(path.resolve(__dirname, '../views/new.html'), {exercieData})
    console.log('tmp')
    config.document = tmp
    try {
        var result = await pdfReactor.convert(config);
        console.log('result')
        fs.writeFile('result.html', tmp, 'utf-8', function(error) {
            if (error) {
                console.log(error);
            }
        });
        await ctx.render('pdf', {
            tmp: "data:application/pdf;base64," + result.document
          })
    } catch (error) {
        await ctx.render('index', {
            title: error
          })
    }
})
router.get('/html', async (ctx, next) => {
    // let tmp = fs.readFileSync(path.resolve(__dirname, '../views/tmp.html'), 'utf-8')
    let tmp = template(path.resolve(__dirname, '../views/studentTmp.html'), {exercieData, arr:[1,2,3]})
    fs.writeFile('result.html', tmp, 'utf-8', function(error) {
        if (error) {
            console.log(error);
        }
    });
    ctx.body= tmp
})
router.get('/pdf', async (ctx, next) => {
    try {
        // Convert document
        const result = await pdfReactor.convert(config);
    
        fs.writeFile('result.pdf', result.document, 'base64', function(error) {
            if (error) {
                console.log(error);
            }
        });
    } catch (error) {
        console.log(error);
    }
  await ctx.render('index', {
    title: 'Hello Koa 2!'
  })
})


module.exports = router
