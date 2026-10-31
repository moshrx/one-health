export const categories = ['Children', 'Adults', 'Female Health', 'Male Health', 'Geriatric'];
export type Patient = { id:string; name:string; age:number; categories:string[]; complaint:string; lastVisit:string; status:string };
export type Entry = { id:string; patientId:string; kind:string; date:string; fields:Record<string,string>; signed:boolean };
export type Workspace = { patients:Patient[]; entries:Entry[]; bookmarks:string[] };
export const initial:Workspace = { patients:[
{id:'OH-1001',name:'Ananya Rao',age:34,categories:['Adults','Female Health'],complaint:'Recurring headaches',lastVisit:'2026-10-31',status:'Follow-up due'},
{id:'OH-1002',name:'Oliver Bennett',age:8,categories:['Children'],complaint:'Seasonal nasal symptoms',lastVisit:'2026-10-30',status:'Active care'},
{id:'OH-1003',name:'Meera Shah',age:67,categories:['Geriatric','Female Health'],complaint:'Joint discomfort',lastVisit:'2026-10-29',status:'Follow-up due'},
{id:'OH-1004',name:'Arjun Patel',age:42,categories:['Adults','Male Health'],complaint:'Sleep concerns',lastVisit:'2026-10-28',status:'Active care'},
{id:'OH-1005',name:'Amelia Clarke',age:29,categories:['Adults','Female Health'],complaint:'Initial consultation',lastVisit:'2026-10-27',status:'New patient'}
],entries:[],bookmarks:[] };
export const books = [ ['WB','William Boericke','Pocket Manual of Homoeopathic Materia Medica','Ochre'],['TA','T. F. Allen','Keynotes and Characteristics','Sage'],['HA','H. C. Allen','Materia Medica','Rose'],['JK','J. T. Kent','Lectures on Homoeopathic Materia Medica','Blue'],['JC','John Henry Clarke','Dictionary of Practical Materia Medica','Sage'],['EN','E. B. Nash','Leaders in Homoeopathic Therapeutics','Ochre'],['SP','Phatak','Materia Medica','Rose'] ];
export const remedies = ['Arnica montana','Nux vomica','Pulsatilla','Bryonia alba','Sulphur','Lycopodium'];
export const rubrics = [ {name:'Head · pain (illustrative)', grades:[2,1,0,3,1,0]}, {name:'Sleep · disturbed (illustrative)', grades:[0,3,1,0,2,1]}, {name:'Generalities · motion (illustrative)', grades:[1,0,2,3,0,1]} ];
export function rank(weights:number[]) {return remedies.map((name,i)=>({name,score:rubrics.reduce((sum,r,j)=>sum+r.grades[i]*weights[j],0)})).sort((a,b)=>b.score-a.score);}
