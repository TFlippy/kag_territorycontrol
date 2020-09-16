uniform sampler2D baseMap;

varying vec2 Texcoord;

uniform float amount;
uniform float res_x;
uniform float res_y;
uniform float scroll_x;
uniform float time;

void main()
{
	if (amount <= 0.0001)
	{
		gl_FragColor = texture2D(baseMap, Texcoord);
	}
	else //apply wave
	{
		vec2 uv = Texcoord;
		float amountmod = (1.0 + sqrt(amount) * 0.2);

		vec2 step = vec2(1.0 / res_x, 1.0 / res_y);

		vec2 soffset = vec2(res_x, res_y) * uv / amountmod + vec2(scroll_x, 0);

		float scaledmod = amountmod * 30.0;

		vec2 sinarg = soffset.xx;
		sinarg += sin(soffset.yx * 0.1) * 20.0;
		sinarg *= vec2(0.1889, 0.601);
		sinarg += sin(vec2(time * 0.31, -time * 0.993)) * scaledmod;
		sinarg *= 0.05;

		float sinamount = (amount / res_y * 0.999);

		vec2 sincomp = vec2(0.0, (sin(sinarg.x) + sin(sinarg.y)) / 2.0);

		vec2 pos = uv + sincomp * sinamount - vec2(min(sinamount, step.x), min(sinamount, step.y));

		pos = clamp(pos, step, vec2(1.0) - step);

		//(visualise distortion)
		//float v = (sincomp.y + 1.0) / 2.0;
		//gl_FragColor = vec4(vec3(v), 1.0);

		//(distort)
		gl_FragColor = texture2D(baseMap, pos);
	}
}
