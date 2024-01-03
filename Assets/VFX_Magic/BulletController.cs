using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BulletController : MonoBehaviour
{
    public float speed;
    public GameObject splash;
    public 
    void Update()
    {
        transform.Translate(Vector3.forward * speed * Time.deltaTime);
        Raycast();
    }

    private void OnTriggerEnter(Collider other) 
    {   
        Destroy(Instantiate(splash, transform.position, splash.transform.rotation), 1.5f);
        Destroy(this.gameObject);
    }

    public void Raycast()
    {
            RaycastHit hit;

            if(Physics.Raycast(transform.position, Vector3.forward, out hit, 10f))
            {
                Vector3 hitNormal = hit.normal;
                float angle = Vector3.Angle(Vector3.up, hitNormal);
                
                    Vector3 cross = Vector3.Cross(Vector3.up, hitNormal);
                    Quaternion targetRot = Quaternion.AngleAxis(angle, cross);
                    //float randomRotZ = Random.Range(-180, 180);
                    splash.transform.rotation = targetRot;
                    Debug.Log("isHitting");
            }
    }
}
