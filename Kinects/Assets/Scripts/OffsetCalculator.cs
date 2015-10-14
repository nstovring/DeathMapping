﻿using UnityEngine;
using System.Collections;
using UnityEngine.Networking;

public class OffsetCalculator : NetworkBehaviour {

    public Vector3 player2Offset;
    public float player2angleOffset;

    public GameObject[] players;
    private float player1AngleFromKinect;

	void Start () {
	
	}


	// Update is called once per frame
    [Server]
	void Update () {
        players = GameObject.FindGameObjectsWithTag("Player");

        if (this.players.Length >= 2) {
            
            player2Offset = players[0].transform.position - players[1].transform.position;
            //kinect1Angle = this.players[0].AngleFromKinect;
            //kinect2Angle = this.players[1].AngleFromKinect;
            player1AngleFromKinect = Mathf.Abs(players[0].transform.GetComponent<CubemanController>().angleFromKinect);

            CubemanController player2Controller = players[1].transform.GetComponent<CubemanController>();

            player2angleOffset = player1AngleFromKinect + Mathf.Abs(player2Controller.angleFromKinect) + Mathf.Abs(player2Controller.angleBetweenCameras);
            SetOffset();
                    
        }
	}

    private void SetOffset()
    {
        players[1].GetComponent<CubemanController>().offset = this.player2Offset;
        players[1].GetComponent<CubemanController>().player1AngleFromKinect = this.player1AngleFromKinect;
    }

}
