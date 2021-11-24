import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';

import 'han_detail.dart';

class MyPageListHanWorkItem extends StatefulWidget {

  String token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, jobSts, junId;
  int index, jobAmt;
  MyPageListHanWorkItem(this.token, this.jobId, this.jobTtl, this.aucMtd, this.jobStDtm, this.bidDlDtm, this.jobAmt, this.index, this.payMtd, this.jobIts, this.jobSts, this.junId);

  @override
  _MyPageListHanWorkItemState createState() => _MyPageListHanWorkItemState();
}

class _MyPageListHanWorkItemState extends State<MyPageListHanWorkItem> {
  final formatter = new NumberFormat("###,###,###,###,###");
  String jobIts;
  @override
  void initState() {
    jobIts = widget.jobIts;
    print(widget.junId);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: (){
        print('junId===================================${widget.junId}');
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageHanDetail(jobId:widget.jobId, junId: widget.junId)));
      },
      child: Card(
        elevation: widget.index == 0 ? 8 : 4,
        shape: widget.index != 0  ? RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),  side: BorderSide( color: Colors.grey[400], )) : null,
        margin: EdgeInsets.only(bottom: 10, left: 1, right: 1),
        child: Padding(
          padding: EdgeInsets.only(top: defaultSize * 1, left: defaultSize * 3),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: defaultSize),
              ),


              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: defaultSize * 3),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        shape: BoxShape.circle),
                  ),
                  Column(
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: defaultSize * 3),
                          padding: EdgeInsets.only(left: 5,top: 5),
                          height: 50,
                          width: defaultSize * 18,
                          child: Text(widget.jobTtl ?? '일거리',
                          style: TextStyle(fontWeight: FontWeight.bold),)),
                      Container(
                        margin: EdgeInsets.only(right: defaultSize * 3,bottom: defaultSize * 1),
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                            (widget.jobAmt != null) ? '금액 : '+formatter.format(widget.jobAmt) +'원': '금액 : 0 원',
                          style: TextStyle(
                          fontSize: defaultSize* 1.7,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                          ),
                          // style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        ),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: defaultSize * 3),
                            child: Text(
                              (widget.aucMtd == "1") ? '선착순' : '입찰식',
                              style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),
                            ),
                            // decoration: BoxDecoration( color: Colors.lightBlue[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: defaultSize * 1),
                            child: Text(
                              (widget.payMtd == "1") ? '직접결제' : '안전결제',
                              style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),
                            ),
                            // decoration: BoxDecoration( color: Colors.pink[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: defaultSize * 1,bottom: defaultSize * 2),
                        margin: EdgeInsets.only(right: defaultSize * 10),
                        child: Container(
                          child: jobStsText(widget.jobSts, defaultSize),
                          // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                        ),

                    ),
                ],
              ),



                    // Expanded(
                    //   child:
                    //   // (jobIts == "0") ? IconButton(icon: Icon(Icons.favorite_border_outlined), iconSize: defaultSize * 2, onPressed: () => sendAttention(context) ) :
                    //   IconButton(icon: Icon(Icons.favorite), iconSize: defaultSize * 2, onPressed: () => print('관심수?') ),
                    // ),
                  ],
                ),
      ],
        ),
    ),
    ),
    );


  }


  jobStsText(String jobSts, double defaultSize){
    if(jobSts  == "1"){ return Text('입찰중 ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "2"){ return Text('진행중 ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "3"){ return Text('완료   ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "5"){ return Text('주니 완료 대기중  ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "8"){ return Text('시간초과',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "9"){ return Text('취소   ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
  }
}