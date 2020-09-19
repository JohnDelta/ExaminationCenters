<html>

<head>hello</head>
<body>

	hello
<script>

console.log("hello");
var dataObject = {
        'id_user':1,
        'id_class':1,
        'id_question':1,
        'answer':1,
        'date':1
    };
    
var http = new XMLHttpRequest();
var url = 'http://localhost:8080/ExaminationCenters/student-exam/exam';
var params = JSON.stringify({data: "john"});
http.open('POST', url, true);

//Send the proper header information along with the request
http.setRequestHeader('Content-type', 'application/json');

http.onreadystatechange = function() {//Call a function when the state changes.
    if(http.readyState == 4 && http.status == 200) {
        let ans = http.responseText;
        console.log("OK")
    } else console.log("ERROR");
}
http.send(params);


</script>

</body>
</html>