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
        shape: widget.index != 0  ? RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),
            // side: BorderSide( color: Colors.grey[400], )
        ) : null,
        margin: EdgeInsets.only(bottom: defaultSize * 0.6, left: defaultSize * 0.1, right: defaultSize * 0.1),
        child: Padding(
          padding: EdgeInsets.only(left: defaultSize * 2.7, top: defaultSize * 1, bottom: defaultSize * 0.9),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: defaultSize * 0.6),
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
                          padding: EdgeInsets.only(left: defaultSize * 0.6,top: defaultSize * 0.6),
                          height: defaultSize * 6,
                          width: defaultSize * 25,
                          child: Text(widget.jobTtl ?? '?????????',
                          style: TextStyle(fontWeight: FontWeight.bold),)),
                      Container(
                        margin: EdgeInsets.only(left: defaultSize * 3,bottom: defaultSize * 1,right: defaultSize * 6.7),
                        width: defaultSize * 17,
                        child: Text(
                            (widget.jobAmt != null) ? '?????? : '+formatter.format(widget.jobAmt) +'???': '?????? : 0 ???',
                          style: TextStyle(
                          fontSize: defaultSize* 1.7,
                          color: Colors.black,
                          // fontWeight: FontWeight.bold
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
                              (widget.aucMtd == "1") ? '?????????' : '?????????',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: defaultSize * 1.7,
                                  // fontWeight: FontWeight.bold
                              ),
                            ),

                            // decoration: BoxDecoration( color: Colors.lightBlue[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                          Container(
                            padding:EdgeInsets.only(bottom: defaultSize * 1),
                            margin: EdgeInsets.only(left: defaultSize * 3,right: defaultSize * 6.7),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey)),
                            child: Text(
                              (widget.payMtd == "1") ? '????????????' : '????????????',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: defaultSize * 1.7,
                                  // fontWeight: FontWeight.bold
                                ),
                            ),

                            // decoration: BoxDecoration( color: Colors.pink[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(right: defaultSize * 7.5),
                        width: defaultSize * 15,
                        // decoration: BoxDecoration( border: Border.all(color: Colors.grey)),
                        child: Container(
                          child: jobStsText(widget.jobSts, defaultSize),
                          padding: EdgeInsets.only(left: defaultSize * 1),
                        ),
                    ),
                      SizedBox(height: defaultSize * 2,)
                ],
              ),



                    // Expanded(
                    //   child:
                    //   // (jobIts == "0") ? IconButton(icon: Icon(Icons.favorite_border_outlined), iconSize: defaultSize * 2, onPressed: () => sendAttention(context) ) :
                    //   IconButton(icon: Icon(Icons.favorite), iconSize: defaultSize * 2, onPressed: () => print('??????????') ),
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
    if(jobSts  == "1"){ return Text('????????? ',style: TextStyle(color: Colors.lightGreen, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),textAlign: TextAlign.left); }
    if(jobSts  == "2"){ return Text('????????? ',style: TextStyle(color: Colors.purple, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),textAlign: TextAlign.left); }
    if(jobSts  == "3"){ return Text('??????   ',style: TextStyle(color: Colors.blue[900], fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),textAlign: TextAlign.left); }
    if(jobSts  == "5"){ return Text('?????? ?????????  ',style: TextStyle(color: Colors.lightBlue, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),textAlign: TextAlign.left,); }
    if(jobSts  == "8"){ return Text('????????????',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),textAlign: TextAlign.left); }
    if(jobSts  == "9"){ return Text('??????   ',style: TextStyle(color: Colors.red, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),textAlign: TextAlign.left); }
  }
}