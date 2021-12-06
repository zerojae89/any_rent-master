import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'mypage_review_write_detail.dart';

class MyPageReviewWirteItem extends StatefulWidget {

  String token, mbrId, jobId, jobTtl, junHan, myId, opId, myNicNm, opNicNm, revCtn;
  int index, totMbrGrd, mbrGrd;
  MyPageReviewWirteItem(this.token, this.index, this.mbrId, this.jobId, this.jobTtl, this.junHan, this.myId, this.opId, this.myNicNm, this.opNicNm, this.revCtn, this.totMbrGrd, this.mbrGrd);
  @override
  _MyPageReviewWirteItemState createState() => _MyPageReviewWirteItemState();
}

class _MyPageReviewWirteItemState extends State<MyPageReviewWirteItem> {

  String jobIts, revCtn, token;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageReviewWriteDetail( jobId:widget.jobId, junHan:  widget.junHan, myId: widget.myId, myNicNm: widget.myNicNm, opId: widget.opId, opNicNm: widget.opNicNm, revCtn: widget.revCtn, totMbrGrd : widget.totMbrGrd, mbrGrd: widget.mbrGrd ))),
      child: Card(
        elevation: widget.index == 0 ? 8 : 4,
        shape: widget.index != 0  ? RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),  side: BorderSide( color: Colors.grey[400], )) : null,
        margin: EdgeInsets.only(bottom: 10, left: 1, right: 1),
        child: Padding(
          padding: EdgeInsets.only(left: 5, top: 10, bottom: 8),
          child: Column(
            children: [
              Container(
                // decoration: BoxDecoration(
                //     border: Border.all(color: Colors.grey)),
                padding: EdgeInsets.only(top: 5, left: 5),
                height: defaultSize * 6,
                width: defaultSize * 34,
                child: Text(widget.jobTtl ?? '일거리',
                  style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
              ),
              Row(
                children: [
                  junView(defaultSize, widget.junHan),
                  SizedBox( width: defaultSize * 2, ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    hanView(defaultSize, widget.junHan),
                  ],
                ),
              ),

                ],
              ),
              Container(
                width: defaultSize * 15,
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.grey
                //   )
                // ),
                margin: EdgeInsets.only(right: defaultSize * 17.4,top: defaultSize*1),
                padding: EdgeInsets.only(bottom: defaultSize * 0.7),
                child: Text(
                  (widget.mbrGrd == 9) ? '후기 작성 하기' : '후기 수정 / 삭제' ,
                  style: TextStyle(color: Colors.green, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget junView(defaultSize, junHan){
    print('junHan ========================== $junHan');
    return Container(
      margin: EdgeInsets.only(left: defaultSize * 4),
      child: Text(
        '신청자 : ${junHan == "J" ? widget.myNicNm : widget.opNicNm}',
        style: TextStyle(color: Colors.blue, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),
      ),
      decoration: BoxDecoration(
        // color: Colors.orange[50],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget hanView(defaultSize, junHan){
    print('junHan ========================== $junHan');
    return Container(
      margin: EdgeInsets.only(left: defaultSize * 2),
      child: Text(
        '완료자 : ${junHan == "H" ? widget.myNicNm : widget.opNicNm}',
        style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),
      ),
      decoration: BoxDecoration(
        // color: Colors.orange[50],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}