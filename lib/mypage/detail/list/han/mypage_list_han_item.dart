import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';
import 'han_detail.dart';

class MyPageListHanWorkItem extends StatefulWidget {

  String token,
      jobId,
      jobTtl,
      aucMtd,
      jobStDtm,
      bidDlDtm,
      payMtd,
      jobIts,
      jobSts,
      junId;
  int index, jobAmt,prfSeq;
  MyPageListHanWorkItem(
      this.token,
      this.jobId,
      this.jobTtl,
      this.aucMtd,
      this.jobStDtm,
      this.bidDlDtm,
      this.jobAmt,
      this.index,
      this.payMtd,
      this.jobIts,
      this.jobSts,
      this.prfSeq);

  @override
  _MyPageListHanWorkItemState createState() => _MyPageListHanWorkItemState();
}

class _MyPageListHanWorkItemState extends State<MyPageListHanWorkItem> {
  final formatter = new NumberFormat("###,###,###,###,###");
  String jobIts;
  int junPrfSeq;

  @override
  void initState() {
    jobIts = widget.jobIts;
    junPrfSeq = widget.prfSeq;
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
        margin: EdgeInsets.only(bottom: 6, left: 1, right: 1),
        child: Padding(
          padding: EdgeInsets.only(left: 25, top: 10, bottom: 8),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: defaultSize * 3),
                    width: defaultSize * 8,
                    height: defaultSize * 10,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow.withOpacity(0.5),width: defaultSize * 0.3),
                        shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: (junPrfSeq == null)
                              ? AssetImage('assets/noimage.jpg')
                              : NetworkImage(
                              '$url/api/mypage/images?recieveToken=$junPrfSeq')),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: defaultSize * 3),
                          padding: EdgeInsets.only(left: 5,top: 5),
                          height: 50,
                          width: defaultSize * 25,
                          child: Text(widget.jobTtl ?? '일거리',
                          style: TextStyle(fontWeight: FontWeight.bold),)),
                      Container(
                        margin: EdgeInsets.only(left: defaultSize * 3,bottom: defaultSize * 1,right: defaultSize * 6.7),
                        width: defaultSize * 17,
                        child: Text(
                            (widget.jobAmt != null) ? '금액 : '+formatter.format(widget.jobAmt) +'원': '금액 : 0 원',
                          style: TextStyle(
                          fontSize: defaultSize* 1.7,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                          ),textAlign: TextAlign.left,
                          // style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        ),
                      Row(
                        children: [
                          Container(
                            padding:EdgeInsets.only(bottom: defaultSize * 1),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey)),
                            child: Text(
                              (widget.aucMtd == "1") ? '선착순' : '입찰식',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: defaultSize * 1.7,
                                  fontWeight: FontWeight.bold),
                            ),

                            // decoration: BoxDecoration( color: Colors.lightBlue[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                          Container(
                            padding:EdgeInsets.only(bottom: defaultSize * 1),
                            margin: EdgeInsets.only(left: defaultSize * 3,right: defaultSize * 6.7),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey)),
                            child: Text(
                              (widget.payMtd == "1") ? '직접결제' : '안전결제',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: defaultSize * 1.7,
                                  fontWeight: FontWeight.bold),
                            ),

                            // decoration: BoxDecoration( color: Colors.pink[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(right: defaultSize * 12.5),
                        width: defaultSize * 10,
                        child: Container(
                          child: jobStsText(widget.jobSts, defaultSize),
                          padding: EdgeInsets.only(left: defaultSize * 1),
                          // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                        ),
                    ),
                      SizedBox(height: defaultSize * 2,)
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
    if(jobSts  == "1"){ return Text('입찰중 ',style: TextStyle(color: Colors.lightGreen, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "2"){ return Text('진행중 ',style: TextStyle(color: Colors.purple, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "3"){ return Text('완료   ',style: TextStyle(color: Colors.blue[900], fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "5"){ return Text('주니 완료 대기중  ',style: TextStyle(color: Colors.amber, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "8"){ return Text('시간초과',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
    if(jobSts  == "9"){ return Text('취소   ',style: TextStyle(color: Colors.red, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),); }
  }
}