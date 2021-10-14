import 'package:any_rent/home/home_server.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';
import 'attention_detail.dart';

class MyPageAttentionItme extends StatefulWidget {
  String token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, jobSts;
  int index, jobAmt;
  MyPageAttentionItme(this.token, this.jobId, this.jobTtl, this.aucMtd, this.jobStDtm, this.bidDlDtm, this.jobAmt, this.index, this.payMtd, this.jobIts, this.jobSts);

  @override
  _MyPageAttentionItmeState createState() => _MyPageAttentionItmeState();
}

class _MyPageAttentionItmeState extends State<MyPageAttentionItme> {
  final formatter = new NumberFormat("###,###,###,###,###");
  String jobIts, jobSts;
  @override
  void initState() {

    jobIts = widget.jobIts;
    jobSts = widget.jobSts;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageAttentionDetail(jobId:widget.jobId))),
      child: Card(
        elevation: widget.index == 0 ? 8 : 4,
        shape: widget.index != 0  ? RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),  side: BorderSide( color: Colors.grey[400], )) : null,
        margin: EdgeInsets.only(bottom: 10, left: 1, right: 1),
        child: Padding(
          padding: EdgeInsets.all(defaultSize * 1.3),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: defaultSize),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.jobTtl ?? '일거리'),
                    Text(
                      (widget.aucMtd == "1") ? '' : '남은 입찰시간 : '+widget.bidDlDtm, //남은시간 카운트 해야됨
                      style: TextStyle(color: Colors.deepOrange, fontSize: defaultSize * 1.2),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    child: Text(
                      (widget.aucMtd == "1") ? '금액 : '+formatter.format(widget.jobAmt) +'원': '금액 : 0 원'
                      // style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      // color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox( width: defaultSize * 0.3, ),
                  Container(
                    child: Text(
                      (widget.aucMtd == "1") ? '선착순' : '입찰식',
                      style: TextStyle(color: Colors.lightBlue, fontSize: defaultSize *1.2, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    // decoration: BoxDecoration( color: Colors.lightBlue[50],  borderRadius: BorderRadius.circular(2), ),
                  ),
                  SizedBox( width: defaultSize * 0.3, ),
                  Container(
                    child: Text(
                      (widget.payMtd == "1") ? '직접결제' : '안전결제',
                      style: TextStyle(color: Colors.pink, fontSize: defaultSize* 1.2, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    // decoration: BoxDecoration( color: Colors.pink[50],  borderRadius: BorderRadius.circular(2), ),
                  ),
                  SizedBox( width: defaultSize * 0.3, ),
                  Container(
                    child: jobStsText(jobSts, defaultSize),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    // decoration: BoxDecoration( color: Colors.pink[50],  borderRadius: BorderRadius.circular(2), ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          "시작 시간 : ${widget.jobStDtm}",
                          style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                    ),
                    Expanded(
                      child:
                      (jobIts == "0") ? IconButton(icon: Icon(Icons.favorite_border_outlined), iconSize: defaultSize * 2, onPressed: () => sendAttention(context) ) :
                      IconButton(icon: Icon(Icons.favorite), iconSize: defaultSize * 2, onPressed: () => sendAttentionDelete(context) ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  sendAttention(BuildContext context) async{
    print('관심 등록');
    try{
      print('token  =========================== ${widget.token}');
      print('jobId  =========================== ${widget.jobId}');
      String result = await homeServer.sendAttention(widget.token, widget.jobId);
      print("sendAttention====================================================$result");
      setState(() =>jobIts = widget.jobId);
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }

  sendAttentionDelete(BuildContext context) async{
    print('관심 취소');
    try{
      print('token  =========================== ${widget.token}');
      print('jobId  =========================== ${widget.jobId}');
      String result = await homeServer.sendAttentionDelete(widget.token, widget.jobId);
      print("sendAttention====================================================$result");
      setState(() =>jobIts = "0");
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }
}

 jobStsText(String jobSts, double defaultSize){
  if(jobSts  == "1"){ return Text('입찰중 ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
  if(jobSts  == "2"){ return Text('진행중 ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
  if(jobSts  == "3"){ return Text('완료   ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
  if(jobSts  == "5"){ return Text('주니 완료 대기중  ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
  if(jobSts  == "8"){ return Text('시간초과',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
  if(jobSts  == "9"){ return Text('취소   ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
}