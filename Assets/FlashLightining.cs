using System.Collections;
using UnityEngine;


public class FlashLightining : MonoBehaviour
{
    public GameObject flashVFX;
    public Vector3 spawnPos;
    public bool spawned;
    public bool isLight;
    public Material cloudsMat;
    public float lightAmmount;
    public float deltaAmmount;

    private void Start() 
    {
        cloudsMat.SetFloat("_LightAmmount", 0);  
    }
    private void Update() 
    {
            if(!isLight)
            {
                StartCoroutine(LightController());
            }   
            if(isLight)
            {
                StartCoroutine(BackLight());
            }
    }

    public void SpawnLightening()
    {
        Destroy(Instantiate(flashVFX, transform.position, flashVFX.transform.rotation), 5f);
    }

    IEnumerator LightController()
    {
        while(lightAmmount <= 1)
        {
            lightAmmount += deltaAmmount * Time.deltaTime;
            cloudsMat.SetFloat("_LightAmmount", lightAmmount);
            yield return null;
        }
        if(!isLight)
        {
            SpawnLightening();
        }
        spawned = false;
        isLight = true;
        yield break;
    }

    IEnumerator BackLight()
    {
        while(lightAmmount > 0)
                {
                    lightAmmount -= deltaAmmount * Time.deltaTime;
                    cloudsMat.SetFloat("_LightAmmount", lightAmmount);
                     yield return null;
                }
                isLight = false;
                deltaAmmount = Random.Range(0.0004f, 0.0007f);
                yield break;
    }
}
